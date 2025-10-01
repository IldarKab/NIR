# основной класс субд
import os


class MyDBMS:
    def __init__(self, data_directory="my_db"):
        self.data_directory = data_directory
        self.tables = {}
        self.schemas = {}

        os.makedirs(data_directory, exist_ok=True)
        self._load_existing_tables()

    def _load_existing_tables(self):
        from table_schema import TableSchema
        from binary_table import BinaryTable

        if not os.path.exists(self.data_directory):
            return

        for filename in os.listdir(self.data_directory):
            if filename.endswith('.schema'):
                table_name = filename[:-7]
                try:
                    schema_path = os.path.join(self.data_directory, filename)
                    schema = TableSchema.load_from_file(schema_path)
                    self.schemas[table_name] = schema

                    table = BinaryTable(schema, self.data_directory)
                    self.tables[table_name] = table
                    table.load_indexes()

                except Exception as e:
                    print(f"Ошибка загрузки таблицы {table_name}: {e}")

    def execute_sql(self, sql):
        sql = sql.strip()
        if not sql:
            return None

        if sql.upper().startswith('CREATE TABLE'):
            return self._execute_create_table(sql)
        elif sql.upper().startswith('SELECT'):
            return self._execute_select(sql)
        elif sql.upper().startswith('INSERT'):
            return self._execute_insert(sql)
        elif sql.upper().startswith('DELETE'):
            return self._execute_delete(sql)
        elif sql.upper().startswith('CREATE INDEX'):
            return self._execute_create_index(sql)
        else:
            raise ValueError(f"Неподдерживаемая команда: {sql}")

    def _execute_create_table(self, sql):
        from sql_parser import SQLParser
        from table_schema import TableSchema
        from binary_table import BinaryTable
        from data_types import IntType, VarcharType

        table_name, columns = SQLParser.parse_create_table(sql)

        if table_name in self.tables:
            return f"Таблица {table_name} уже существует"

        schema = TableSchema(table_name)
        for col_name, col_type, max_length in columns:
            if col_type.upper() == 'INT':
                data_type = IntType()
            elif col_type.upper() == 'VARCHAR':
                data_type = VarcharType(max_length)
            else:
                raise ValueError(f"Неподдерживаемый тип: {col_type}")

            schema.add_column(col_name, data_type)

        schema_path = os.path.join(self.data_directory, f"{table_name}.schema")
        schema.save_to_file(schema_path)

        table = BinaryTable(schema, self.data_directory)

        self.schemas[table_name] = schema
        self.tables[table_name] = table

        return f"Таблица {table_name} создана"

    def _execute_select(self, sql):
        from sql_parser import SQLParser

        params = SQLParser.parse_select(sql)
        table_name = params['table']

        if table_name not in self.tables:
            raise ValueError(f"Таблица {table_name} не найдена")

        table = self.tables[table_name]

        if params['where_column']:
            result = table.select_where(params['where_column'], params['where_value'])
        else:
            result = table.select_all()

        if params['columns'] != ['*']:
            filtered_result = []
            for row in result:
                filtered_row = {col: row.get(col) for col in params['columns'] if col in row}
                filtered_result.append(filtered_row)
            result = filtered_result

        return result

    def _execute_insert(self, sql):
        from sql_parser import SQLParser

        params = SQLParser.parse_insert(sql)
        table_name = params['table']

        if table_name not in self.tables:
            raise ValueError(f"Таблица {table_name} не найдена")

        table = self.tables[table_name]
        row_number = table.insert_row(params['data'])
        table.save_indexes()

        return f"Строка вставлена (номер {row_number})"

    def _execute_delete(self, sql):
        from sql_parser import SQLParser

        params = SQLParser.parse_delete(sql)
        table_name = params['table']

        if table_name not in self.tables:
            raise ValueError(f"Таблица {table_name} не найдена")

        table = self.tables[table_name]

        if params['where_column']:
            deleted_count = table.delete_where(params['where_column'], params['where_value'])
        else:
            deleted_count = table.delete_all()

        table.save_indexes()
        return f"Удалено строк: {deleted_count}"

    def _execute_create_index(self, sql):
        import re
        match = re.match(r'CREATE\s+INDEX\s+ON\s+(\w+)\s*\((\w+)\)', sql, re.IGNORECASE)
        if not match:
            raise ValueError("Синтаксис: CREATE INDEX ON table_name (column_name)")

        table_name = match.group(1)
        column_name = match.group(2)

        if table_name not in self.tables:
            raise ValueError(f"Таблица {table_name} не найдена")

        table = self.tables[table_name]
        table.create_index(column_name)
        table.save_indexes()

        return f"Индекс создан на {table_name}.{column_name}"

    def get_table_info(self, table_name):
        if table_name not in self.tables:
            raise ValueError(f"Таблица {table_name} не найдена")

        table = self.tables[table_name]
        schema = self.schemas[table_name]

        return {
            'name': table_name,
            'row_count': table.row_count,
            'row_size_bytes': schema.get_row_size(),
            'columns': [
                {
                    'name': col.name,
                    'type': type(col.data_type).__name__,
                    'size_bytes': col.get_size(),
                    'max_length': getattr(col.data_type, 'max_length', None)
                }
                for col in schema.columns
            ],
            'indexes': list(table.index_manager.indexes.keys())
        }

    def list_tables(self):
        return list(self.tables.keys())

    def drop_table(self, table_name):
        if table_name not in self.tables:
            raise ValueError(f"Таблица {table_name} не найдена")

        # Удаляем файлы
        data_file = os.path.join(self.data_directory, f"{table_name}.dat")
        schema_file = os.path.join(self.data_directory, f"{table_name}.schema")

        if os.path.exists(data_file):
            os.remove(data_file)
        if os.path.exists(schema_file):
            os.remove(schema_file)

        # Удаляем файлы индексов
        for filename in os.listdir(self.data_directory):
            if filename.startswith(f"{table_name}_") and filename.endswith('.idx'):
                os.remove(os.path.join(self.data_directory, filename))

        del self.tables[table_name]
        del self.schemas[table_name]

        return f"Таблица {table_name} удалена"
