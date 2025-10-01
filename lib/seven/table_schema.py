# схема таблицы
import json


class Column:

    def __init__(self, name, data_type):
        self.name = name
        self.data_type = data_type

    def get_size(self):
        return self.data_type.get_size()


class TableSchema:

    def __init__(self, table_name):
        self.table_name = table_name
        self.columns = []

    def add_column(self, name, data_type):
        column = Column(name, data_type)
        self.columns.append(column)

    def get_column(self, name):
        for column in self.columns:
            if column.name == name:
                return column
        raise ValueError(f"Столбец {name} не найден")

    def get_row_size(self):
        return sum(col.get_size() for col in self.columns)

    def serialize_row(self, row_data):
        result = b''
        for column in self.columns:
            value = row_data.get(column.name)
            result += column.data_type.serialize(value)
        return result

    def deserialize_row(self, data):
        result = {}
        offset = 0
        for column in self.columns:
            size = column.get_size()
            column_data = data[offset:offset + size]
            result[column.name] = column.data_type.deserialize(column_data)
            offset += size
        return result

    def save_to_file(self, filepath):
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

            if isinstance(column.data_type, VarcharType):
                col_data['max_length'] = column.data_type.max_length

            schema_data['columns'].append(col_data)

        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(schema_data, f, indent=2, ensure_ascii=False)

    @classmethod
    def load_from_file(cls, filepath):
        from data_types import IntType, VarcharType

        with open(filepath, 'r', encoding='utf-8') as f:
            schema_data = json.load(f)

        schema = cls(schema_data['table_name'])

        for col_data in schema_data['columns']:
            if col_data['type'] == 'IntType':
                data_type = IntType()
            elif col_data['type'] == 'VarcharType':
                data_type = VarcharType(col_data['max_length'])
            else:
                raise ValueError(f"Неизвестный тип: {col_data['type']}")

            schema.add_column(col_data['name'], data_type)

        return schema
