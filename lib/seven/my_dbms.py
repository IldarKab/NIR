# Основной класс собственной СУБД
# Координирует работу всех компонентов: парсер, схемы, таблицы, индексы

import os


class MyDBMS:
    """
    Главный класс СУБД, объединяющий все компоненты системы.

    Архитектура:
    - Управляет множественными таблицами
    - Координирует парсинг SQL и выполнение команд
    - Обеспечивает персистентность данных и схем
    - Автоматически загружает существующие таблицы при запуске

    Файловая структура на диске:
    data_directory/
    table1.dat     # бинарные данные таблицы
    table1.schema  # схема таблицы в JSON
    table1_col.idx # индексы для колонок

    """

    def __init__(self, data_directory="my_db"):
        """
        Инициализирует СУБД с указанной папкой для данных.

        data_directory - папка для хранения всех файлов СУБД
        tables - словарь {имя_таблицы: объект_BinaryTable}
        schemas - словарь {имя_таблицы: объект_TableSchema}

        При запуске автоматически загружает существующие таблицы.
        """
        self.data_directory = data_directory
        self.tables = {}    # Активные таблицы в памяти
        self.schemas = {}   # Схемы таблиц

        os.makedirs(data_directory, exist_ok=True)
        self._load_existing_tables()

    def _load_existing_tables(self):
        """
        Загружает все существующие таблицы при запуске СУБД.

        Алгоритм:
        1. Сканирует папку на наличие .schema файлов
        2. Для каждой схемы создает объект TableSchema
        3. Создает соответствующий BinaryTable
        4. Загружает индексы таблицы

        Это обеспечивает персистентность - СУБД "помнит" свое состояние
        после перезапуска.
        """
        from table_schema import TableSchema
        from binary_table import BinaryTable

        if not os.path.exists(self.data_directory):
            return

        # Ищем все файлы схем
        for filename in os.listdir(self.data_directory):
            if filename.endswith('.schema'):
                table_name = filename[:-7]  # Убираем .schema
                try:
                    # Загружаем схему
                    schema_path = os.path.join(self.data_directory, filename)
                    schema = TableSchema.load_from_file(schema_path)
                    self.schemas[table_name] = schema

                    # Создаем таблицу и загружаем данные
                    table = BinaryTable(schema, self.data_directory)
                    self.tables[table_name] = table

                    # Загружаем индексы (если есть)
                    table.index_manager.load_all(self.data_directory)

                except Exception as e:
                    print(f"Ошибка загрузки таблицы {table_name}: {e}")

    def execute_sql(self, sql):
        """
        Главный метод для выполнения SQL команд.

        Поддерживаемые команды:
        - CREATE TABLE table_name (columns...)
        - SELECT columns FROM table [WHERE condition]
        - INSERT INTO table (columns) VALUES (values)
        - DELETE FROM table [WHERE condition]
        - CREATE INDEX ON table (column)

        Алгоритм:
        1. Определяет тип команды по первым словам
        2. Делегирует выполнение соответствующему методу
        3. Возвращает результат или сообщение об успехе
        """
        sql = sql.strip()
        if not sql:
            return None

        # Маршрутизация команд
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
        """
        Выполняет CREATE TABLE команду.

        Процесс:
        1. Парсит SQL через SQLParser
        2. Создает объект TableSchema с соответствующими типами данных
        3. Сохраняет схему в .schema файл
        4. Создает BinaryTable для работы с данными
        5. Регистрирует таблицу в системе

        Возвращает сообщение об успехе или ошибке.
        """
        from sql_parser import SQLParser
        from table_schema import TableSchema
        from binary_table import BinaryTable
        from data_types import IntType, VarcharType

        table_name, columns = SQLParser.parse_create_table(sql)

        # Проверяем уникальность имени
        if table_name in self.tables:
            return f"Таблица {table_name} уже существует"

        # Создаем схему
        schema = TableSchema(table_name)
        for col_name, col_type, max_length in columns:
            if col_type.upper() == 'INT':
                data_type = IntType()
            elif col_type.upper() == 'VARCHAR':
                data_type = VarcharType(max_length)
            else:
                raise ValueError(f"Неподдерживаемый тип: {col_type}")

            schema.add_column(col_name, data_type)

        # Сохраняем схему на диск
        schema_path = os.path.join(self.data_directory, f"{table_name}.schema")
        schema.save_to_file(schema_path)

        # Создаем таблицу
        table = BinaryTable(schema, self.data_directory)

        # Регистрируем в системе
        self.schemas[table_name] = schema
        self.tables[table_name] = table

        return f"Таблица {table_name} создана"

    def _execute_select(self, sql):
        """
        Выполняет SELECT команду.

        Процесс:
        1. Парсит SQL для извлечения: колонки, таблица, WHERE условие
        2. Находит таблицу в системе
        3. Выполняет поиск (с индексом или без)
        4. Фильтрует колонки, если указаны конкретные (не *)

        Возвращает список словарей с результатами.
        """
        from sql_parser import SQLParser

        params = SQLParser.parse_select(sql)
        table_name = params['table']

        if table_name not in self.tables:
            raise ValueError(f"Таблица {table_name} не найдена")

        table = self.tables[table_name]

        # Выполняем поиск
        if params['where_column']:
            # SELECT с WHERE условием
            result = table.select_where(params['where_column'], params['where_value'])
        else:
            # SELECT всех строк
            result = table.select_all()

        # Фильтруем колонки, если нужно
        if params['columns'] != ['*']:
            filtered_result = []
            for row in result:
                # Оставляем только запрошенные колонки
                filtered_row = {col: row.get(col) for col in params['columns'] if col in row}
                filtered_result.append(filtered_row)
            result = filtered_result

        return result

    def _execute_insert(self, sql):
        """
        Выполняет INSERT команду.

        Процесс:
        1. Парсит SQL для извлечения таблицы и данных
        2. Находит таблицу в системе
        3. Вставляет строку (автоматически обновляются индексы)
        4. Сохраняет индексы на диск

        Возвращает сообщение с номером вставленной строки.
        """
        from sql_parser import SQLParser

        params = SQLParser.parse_insert(sql)
        table_name = params['table']

        if table_name not in self.tables:
            raise ValueError(f"Таблица {table_name} не найдена")

        table = self.tables[table_name]
        row_number = table.insert_row(params['data'])

        # Сохраняем обновленные индексы
        table.index_manager.save_all(self.data_directory)

        return f"Строка вставлена (номер {row_number})"

    def _execute_delete(self, sql):
        """
        Выполняет DELETE команду.

        Процесс:
        1. Парсит SQL для извлечения таблицы и WHERE условия
        2. Находит таблицу в системе
        3. Удаляет строки (все или по условию)
        4. Сохраняет обновленные индексы

        Возвращает количество удаленных строк.
        """
        from sql_parser import SQLParser

        params = SQLParser.parse_delete(sql)
        table_name = params['table']

        if table_name not in self.tables:
            raise ValueError(f"Таблица {table_name} не найдена")

        table = self.tables[table_name]

        if params['where_column']:
            # Удаление по условию
            deleted_count = table.delete_where(params['where_column'], params['where_value'])
        else:
            # Удаление всех строк
            deleted_count = table.delete_all()

        # Сохраняем обновленные индексы
        table.index_manager.save_all(self.data_directory)
        return f"Удалено строк: {deleted_count}"

    def _execute_create_index(self, sql):
        """
        Выполняет CREATE INDEX команду.

        Синтаксис: CREATE INDEX ON table_name (column_name)

        Процесс:
        1. Парсит SQL с помощью регулярного выражения
        2. Находит таблицу и колонку
        3. Создает индекс (автоматически заполняется для существующих данных)
        4. Сохраняет индекс на диск

        Возвращает сообщение об успехе.
        """
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
        table.index_manager.save_all(self.data_directory)

        return f"Индекс создан на {table_name}.{column_name}"

    def get_table_info(self, table_name):
        """
        Возвращает подробную информацию о таблице.

        Включает:
        - Количество строк
        - Размер строки в байтах
        - Список колонок с типами и размерами
        - Список созданных индексов

        """
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
        """
        Возвращает список всех таблиц в СУБД.
        """
        return list(self.tables.keys())

    def drop_table(self, table_name):
        """
        Удаляет таблицу полностью.

        Процесс:
        1. Проверяет существование таблицы
        2. Удаляет файлы данных (.dat) и схемы (.schema)
        3. Удаляет файлы индексов (.idx)
        4. Убирает таблицу из памяти

        """
        if table_name not in self.tables:
            raise ValueError(f"Таблица {table_name} не найдена")

        # Удаляем основные файлы
        data_file = os.path.join(self.data_directory, f"{table_name}.dat")
        schema_file = os.path.join(self.data_directory, f"{table_name}.schema")

        if os.path.exists(data_file):
            os.remove(data_file)
        if os.path.exists(schema_file):
            os.remove(schema_file)

        # Удаляем файлы индексов
        for filename in os.listdir(self.data_directory):
            if filename.startswith(f"{table_name}_") and filename.endswith('.idx'):
                index_file = os.path.join(self.data_directory, filename)
                os.remove(index_file)

        # Убираем из памяти
        del self.tables[table_name]
        del self.schemas[table_name]

        return f"Таблица {table_name} удалена"

        # Удаляем файлы индексов
        for filename in os.listdir(self.data_directory):
            if filename.startswith(f"{table_name}_") and filename.endswith('.idx'):
                os.remove(os.path.join(self.data_directory, filename))

        del self.tables[table_name]
        del self.schemas[table_name]

        return f"Таблица {table_name} удалена"
