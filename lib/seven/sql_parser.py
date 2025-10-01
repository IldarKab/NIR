# sql-парсер для обработки команл
import re


class SQLParser:

    @staticmethod
    def parse_create_table(sql):
        sql = re.sub(r'\s+', ' ', sql.strip())

        match = re.match(r'CREATE\s+TABLE\s+(\w+)\s*\((.*)\)', sql, re.IGNORECASE)
        if not match:
            raise ValueError("Неверный синтаксис CREATE TABLE")

        table_name = match.group(1)
        columns_str = match.group(2)

        columns = []
        for col_def in columns_str.split(','):
            col_def = col_def.strip()

            # INT столбец
            int_match = re.match(r'(\w+)\s+INT', col_def, re.IGNORECASE)
            if int_match:
                columns.append((int_match.group(1), 'INT', None))
                continue

            # VARCHAR столбец
            varchar_match = re.match(r'(\w+)\s+VARCHAR\s*\((\d+)\)', col_def, re.IGNORECASE)
            if varchar_match:
                col_name = varchar_match.group(1)
                max_length = int(varchar_match.group(2))
                columns.append((col_name, 'VARCHAR', max_length))
                continue

            raise ValueError(f"Неизвестный тип столбца: {col_def}")

        return table_name, columns

    @staticmethod
    def parse_select(sql):
        sql = re.sub(r'\s+', ' ', sql.strip())

        result = {
            'columns': [],
            'table': '',
            'where_column': None,
            'where_value': None
        }

        base_match = re.match(r'SELECT\s+(.+?)\s+FROM\s+(\w+)(?:\s+WHERE\s+(.+))?', sql, re.IGNORECASE)
        if not base_match:
            raise ValueError("Неверный синтаксис SELECT")

        # Столбцы
        columns_str = base_match.group(1).strip()
        if columns_str == '*':
            result['columns'] = ['*']
        else:
            result['columns'] = [col.strip() for col in columns_str.split(',')]

        # Таблица
        result['table'] = base_match.group(2)

        # WHERE условие
        where_clause = base_match.group(3)
        if where_clause:
            where_match = re.match(r'(\w+)\s*=\s*(.+)', where_clause.strip(), re.IGNORECASE)
            if where_match:
                result['where_column'] = where_match.group(1)
                value_str = where_match.group(2).strip()

                if value_str.startswith('"') and value_str.endswith('"'):
                    result['where_value'] = value_str[1:-1]
                elif value_str.isdigit():
                    result['where_value'] = int(value_str)
                else:
                    raise ValueError(f"Неверное значение в WHERE: {value_str}")

        return result

    @staticmethod
    def parse_insert(sql):
        sql = re.sub(r'\s+', ' ', sql.strip())

        match = re.match(r'INSERT\s+INTO\s+(\w+)\s*\(([^)]+)\)\s*VALUES\s*\(([^)]+)\)', sql, re.IGNORECASE)
        if not match:
            raise ValueError("Неверный синтаксис INSERT")

        table_name = match.group(1)
        columns_str = match.group(2)
        values_str = match.group(3)

        columns = [col.strip() for col in columns_str.split(',')]

        values = []
        for val in values_str.split(','):
            val = val.strip()
            if val.startswith('"') and val.endswith('"'):
                values.append(val[1:-1])
            elif val.isdigit():
                values.append(int(val))
            else:
                raise ValueError(f"Неверное значение: {val}")

        if len(columns) != len(values):
            raise ValueError("Количество столбцов и значений не совпадает")

        return {
            'table': table_name,
            'data': dict(zip(columns, values))
        }

    @staticmethod
    def parse_delete(sql):
        sql = re.sub(r'\s+', ' ', sql.strip())

        result = {
            'table': '',
            'where_column': None,
            'where_value': None
        }

        # DELETE * FROM table
        if re.match(r'DELETE\s+\*', sql, re.IGNORECASE):
            match = re.match(r'DELETE\s+\*\s+FROM\s+(\w+)', sql, re.IGNORECASE)
            if match:
                result['table'] = match.group(1)
                return result

        # DELETE FROM table [WHERE ...]
        match = re.match(r'DELETE\s+FROM\s+(\w+)(?:\s+WHERE\s+(.+))?', sql, re.IGNORECASE)
        if not match:
            raise ValueError("Неверный синтаксис DELETE")

        result['table'] = match.group(1)

        where_clause = match.group(2)
        if where_clause:
            where_match = re.match(r'(\w+)\s*=\s*(.+)', where_clause.strip(), re.IGNORECASE)
            if where_match:
                result['where_column'] = where_match.group(1)
                value_str = where_match.group(2).strip()

                if value_str.startswith('"') and value_str.endswith('"'):
                    result['where_value'] = value_str[1:-1]
                elif value_str.isdigit():
                    result['where_value'] = int(value_str)
                else:
                    raise ValueError(f"Неверное значение в WHERE: {value_str}")

        return result
