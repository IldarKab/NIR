# Система схем таблиц для собственной СУБД
# Определяет структуру таблиц и методы работы с данными строк

import json


class Column:
    # Представляет одну колонку в таблице.
    # Содержит имя колонки и её тип данных.

    def __init__(self, name, data_type):
        # name - имя колонки (строка)
        # data_type - экземпляр класса типа данных (IntType или VarcharType)

        self.name = name
        self.data_type = data_type

    def get_size(self):
        # Возвращает размер колонки в байтах.
        # Делегирует вызов типу данных.
        return self.data_type.get_size()


class TableSchema:
    # Описывает структуру таблицы: имя и список колонок.
    # Отвечает за сериализацию/десериализацию целых строк таблицы
    # и сохранение/загрузку схемы в файл.

    def __init__(self, table_name):
        # table_name - имя таблицы
        # columns - список объектов Column
        self.table_name = table_name
        self.columns = []

    def add_column(self, name, data_type):
        # Добавляет новую колонку в схему таблицы.
        # Создает объект Column и добавляет в список.
        column = Column(name, data_type)
        self.columns.append(column)

    def get_column(self, name):
        # Находит колонку по имени.
        # Возвращает объект Column или бросает исключение, если не найдена.
        for column in self.columns:
            if column.name == name:
                return column
        raise ValueError(f"Столбец {name} не найден")

    def get_row_size(self):
        # Вычисляет общий размер одной строки в байтах.
        # Суммирует размеры всех колонок.
        # Используется для расчета позиций строк в файле.
        return sum(col.get_size() for col in self.columns)

    def serialize_row(self, row_data):
        """
        Преобразует словарь с данными строки в байты для записи в файл.

        row_data - словарь {имя_колонки: значение}
        Возвращает bytes - бинарное представление строки

        Процесс:
        1. Проходит по всем колонкам в порядке их определения
        2. Для каждой колонки берет значение из row_data
        3. Сериализует значение через тип данных колонки
        4. Склеивает все байты в одну последовательность

        Важно: порядок колонок фиксирован, что обеспечивает
        одинаковую структуру всех строк в файле.
        """
        result = b''
        for column in self.columns:
            value = row_data.get(column.name)
            result += column.data_type.serialize(value)
        return result

    def deserialize_row(self, data):
        """
        Преобразует байты из файла обратно в словарь с данными строки.

        data - bytes, прочитанные из файла (размер = get_row_size())
        Возвращает словарь {имя_колонки: значение}

        Процесс:
        1. Проходит по колонкам в том же порядке, что и при сериализации
        2. Для каждой колонки вычисляет offset (смещение в байтах)
        3. Извлекает нужное количество байт для колонки
        4. Десериализует через тип данных колонки
        5. Собирает результат в словарь

        offset увеличивается на размер каждой колонки, обеспечивая
        правильное чтение всех полей.
        """
        result = {}
        offset = 0
        for column in self.columns:
            size = column.get_size()
            column_data = data[offset:offset + size]
            result[column.name] = column.data_type.deserialize(column_data)
            offset += size
        return result

    def save_to_file(self, filepath):

        # Сохраняет схему таблицы в JSON файл.
        # Это позволяет восстановить структуру таблицы при перезапуске СУБД.

        # Сохраняет:
        # - Имя таблицы
        # - Список колонок с их именами и типами
        # - Для VARCHAR дополнительно сохраняет max_length

        from data_types import VarcharType
        schema_data = {
            'table_name': self.table_name,
            'columns': []
        }

        for column in self.columns:
            col_data = {
                'name': column.name,
                'type': type(column.data_type).__name__
            }

            # Для VARCHAR нужно сохранить максимальную длину
            if isinstance(column.data_type, VarcharType):
                col_data['max_length'] = column.data_type.max_length

            schema_data['columns'].append(col_data)

        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(schema_data, f, indent=2, ensure_ascii=False)

    @classmethod
    def load_from_file(cls, filepath):
        # Загружает схему таблицы из JSON файла.
        # Восстанавливает объекты типов данных и создает схему.

        # Возвращает полностью восстановленный объект TableSchema.
        from data_types import IntType, VarcharType

        with open(filepath, 'r', encoding='utf-8') as f:
            schema_data = json.load(f)

        schema = cls(schema_data['table_name'])

        # Восстанавливаем каждую колонку
        for col_data in schema_data['columns']:
            if col_data['type'] == 'IntType':
                data_type = IntType()
            elif col_data['type'] == 'VarcharType':
                data_type = VarcharType(col_data['max_length'])
            else:
                raise ValueError(f"Неизвестный тип: {col_data['type']}")

            schema.add_column(col_data['name'], data_type)

        return schema
