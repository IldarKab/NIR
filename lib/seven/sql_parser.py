# SQL парсер для обработки основных команд СУБД
# Поддерживает: CREATE TABLE, SELECT, INSERT, DELETE, CREATE INDEX

import re


class SQLParser:
    """
    Простой SQL парсер, использующий регулярные выражения.

    Не претендует на полную совместимость с SQL стандартом,
    но поддерживает основные операции для учебной СУБД.

    Все методы статические - парсер не хранит состояние.
    """

    @staticmethod
    def parse_create_table(sql):
        """
        Парсит команду CREATE TABLE.

        Поддерживаемый синтаксис:
        CREATE TABLE table_name (
            column1 INT,
            column2 VARCHAR(length),
            ...
        )

        Возвращает: (table_name, [(col_name, col_type, max_length), ...])

        Алгоритм:
        1. Нормализует пробелы в SQL
        2. Извлекает имя таблицы и список колонок
        3. Парсит каждую колонку отдельно
        4. Проверяет поддерживаемые типы: INT и VARCHAR(n)
        """
        # Убираем лишние пробелы для упрощения парсинга
        sql = re.sub(r'\s+', ' ', sql.strip())

        # Основная структура: CREATE TABLE name (columns)
        match = re.match(r'CREATE\s+TABLE\s+(\w+)\s*\((.*)\)', sql, re.IGNORECASE)
        if not match:
            raise ValueError("Неверный синтаксис CREATE TABLE")

        table_name = match.group(1)
        columns_str = match.group(2)

        columns = []
        # Разбираем каждую колонку
        for col_def in columns_str.split(','):
            col_def = col_def.strip()

            # Парсим INT столбец
            int_match = re.match(r'(\w+)\s+INT', col_def, re.IGNORECASE)
            if int_match:
                columns.append((int_match.group(1), 'INT', None))
                continue

            # Парсим VARCHAR столбец с указанием длины
            varchar_match = re.match(r'(\w+)\s+VARCHAR\s*\((\d+)\)', col_def, re.IGNORECASE)
            if varchar_match:
                col_name = varchar_match.group(1)
                max_length = int(varchar_match.group(2))
                columns.append((col_name, 'VARCHAR', max_length))
                continue

            # Если ни один паттерн не подошел - ошибка
            raise ValueError(f"Неизвестный тип столбца: {col_def}")

        return table_name, columns

    @staticmethod
    def parse_select(sql):
        """
        Парсит команду SELECT.

        Поддерживаемый синтаксис:
        SELECT * FROM table
        SELECT col1, col2 FROM table
        SELECT * FROM table WHERE column = value

        Возвращает словарь с полями:
        - columns: список колонок или ['*']
        - table: имя таблицы
        - where_column: колонка в условии WHERE (или None)
        - where_value: значение в условии WHERE (или None)

        Алгоритм:
        1. Извлекает основные части: SELECT ... FROM ... WHERE ...
        2. Парсит список колонок (поддерживает * и перечисление)
        3. Извлекает имя таблицы
        4. Парсит WHERE условие (только равенство)
        5. Определяет тип значения (строка в кавычках или число)
        """
        sql = re.sub(r'\s+', ' ', sql.strip())

        result = {
            'columns': [],
            'table': '',
            'where_column': None,
            'where_value': None
        }

        # Основная структура с опциональным WHERE
        base_match = re.match(r'SELECT\s+(.+?)\s+FROM\s+(\w+)(?:\s+WHERE\s+(.+))?', sql, re.IGNORECASE)
        if not base_match:
            raise ValueError("Неверный синтаксис SELECT")

        # Парсим список колонок
        columns_str = base_match.group(1).strip()
        if columns_str == '*':
            result['columns'] = ['*']
        else:
            # Разделяем по запятым и убираем пробелы
            result['columns'] = [col.strip() for col in columns_str.split(',')]

        # Извлекаем имя таблицы
        result['table'] = base_match.group(2)

        # Парсим WHERE условие (если есть)
        where_clause = base_match.group(3)
        if where_clause:
            # Поддерживаем только равенство: column = value
            where_match = re.match(r'(\w+)\s*=\s*(.+)', where_clause.strip(), re.IGNORECASE)
            if where_match:
                result['where_column'] = where_match.group(1)
                value_str = where_match.group(2).strip()

                # Определяем тип значения
                if value_str.startswith('"') and value_str.endswith('"'):
                    # Строка в кавычках
                    result['where_value'] = value_str[1:-1]
                elif value_str.isdigit():
                    # Число
                    result['where_value'] = int(value_str)
                else:
                    raise ValueError(f"Неверное значение в WHERE: {value_str}")

        return result

    @staticmethod
    def parse_insert(sql):
        """
        Парсит команду INSERT.

        Поддерживаемый синтаксис:
        INSERT INTO table (col1, col2) VALUES (val1, val2)

        Возвращает словарь:
        - table: имя таблицы
        - data: словарь {колонка: значение}

        Алгоритм:
        1. Извлекает имя таблицы, список колонок и значений
        2. Парсит колонки (разделение по запятым)
        3. Парсит значения с определением типов
        4. Проверяет соответствие количества колонок и значений
        5. Создает словарь для вставки
        """
        sql = re.sub(r'\s+', ' ', sql.strip())

        # Структура: INSERT INTO table (columns) VALUES (values)
        match = re.match(r'INSERT\s+INTO\s+(\w+)\s*\(([^)]+)\)\s*VALUES\s*\(([^)]+)\)', sql, re.IGNORECASE)
        if not match:
            raise ValueError("Неверный синтаксис INSERT")

        table_name = match.group(1)
        columns_str = match.group(2)
        values_str = match.group(3)

        # Парсим список колонок
        columns = [col.strip() for col in columns_str.split(',')]

        # Парсим значения
        values = []
        for val in values_str.split(','):
            val = val.strip()
            if val.startswith('"') and val.endswith('"'):
                # Строковое значение
                values.append(val[1:-1])
            elif val.isdigit():
                # Числовое значение
                values.append(int(val))
            else:
                raise ValueError(f"Неверное значение: {val}")

        # Проверяем соответствие количества
        if len(columns) != len(values):
            raise ValueError("Количество столбцов и значений не совпадает")

        return {
            'table': table_name,
            'data': dict(zip(columns, values))  # Создаем словарь колонка->значение
        }

    @staticmethod
    def parse_delete(sql):
        """
        Парсит команду DELETE.

        Поддерживаемый синтаксис:
        DELETE * FROM table (удалить все)
        DELETE FROM table (удалить все)
        DELETE FROM table WHERE column = value

        Возвращает словарь:
        - table: имя таблицы
        - where_column: колонка в условии (или None для удаления всех)
        - where_value: значение в условии (или None)

        Алгоритм:
        1. Проверяет специальный случай DELETE * FROM (удаление всех)
        2. Парсит обычный DELETE FROM с опциональным WHERE
        3. Обрабатывает WHERE условие аналогично SELECT
        """
        sql = re.sub(r'\s+', ' ', sql.strip())

        result = {
            'table': '',
            'where_column': None,
            'where_value': None
        }

        # Специальный случай: DELETE * FROM table (удалить все)
        if re.match(r'DELETE\s+\*', sql, re.IGNORECASE):
            match = re.match(r'DELETE\s+\*\s+FROM\s+(\w+)', sql, re.IGNORECASE)
            if match:
                result['table'] = match.group(1)
                return result

        # Обычный DELETE FROM с опциональным WHERE
        match = re.match(r'DELETE\s+FROM\s+(\w+)(?:\s+WHERE\s+(.+))?', sql, re.IGNORECASE)
        if not match:
            raise ValueError("Неверный синтаксис DELETE")

        result['table'] = match.group(1)

        # Парсим WHERE условие (аналогично SELECT)
        where_clause = match.group(2)
        if where_clause:
            where_match = re.match(r'(\w+)\s*=\s*(.+)', where_clause.strip(), re.IGNORECASE)
            if where_match:
                result['where_column'] = where_match.group(1)
                value_str = where_match.group(2).strip()

                # Определяем тип значения
                if value_str.startswith('"') and value_str.endswith('"'):
                    result['where_value'] = value_str[1:-1]
                elif value_str.isdigit():
                    result['where_value'] = int(value_str)
                else:
                    raise ValueError(f"Неверное значение в WHERE: {value_str}")

        return result
