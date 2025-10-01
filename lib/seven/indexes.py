# система индексов
import struct
import os
from collections import defaultdict


class SimpleIndex:

    def __init__(self, table_name, column_name):
        self.table_name = table_name
        self.column_name = column_name
        self.index_data = defaultdict(list)

    def add_entry(self, value, row_number):
        if isinstance(value, int):
            self.index_data[value].append(row_number)

    def remove_entry(self, value, row_number):
        if value in self.index_data and row_number in self.index_data[value]:
            self.index_data[value].remove(row_number)
            if not self.index_data[value]:
                del self.index_data[value]

    def find_rows(self, value):
        return self.index_data.get(value, [])

    def clear(self):
        self.index_data.clear()

    def save_to_file(self, directory):
        filename = f"{self.table_name}_{self.column_name}.idx"
        filepath = os.path.join(directory, filename)

        with open(filepath, 'wb') as f:
            f.write(struct.pack('<I', len(self.index_data)))

            for value in sorted(self.index_data.keys()):
                row_numbers = self.index_data[value]
                f.write(struct.pack('<Q', value))
                f.write(struct.pack('<I', len(row_numbers)))
                for row_num in row_numbers:
                    f.write(struct.pack('<I', row_num))

    def load_from_file(self, directory):
        filename = f"{self.table_name}_{self.column_name}.idx"
        filepath = os.path.join(directory, filename)

        if not os.path.exists(filepath):
            return False

        self.index_data.clear()

        with open(filepath, 'rb') as f:
            count_data = f.read(4)
            if len(count_data) != 4:
                return False
            count = struct.unpack('<I', count_data)[0]

            for _ in range(count):
                value_data = f.read(8)
                if len(value_data) != 8:
                    return False
                value = struct.unpack('<Q', value_data)[0]

                row_count_data = f.read(4)
                if len(row_count_data) != 4:
                    return False
                row_count = struct.unpack('<I', row_count_data)[0]

                row_numbers = []
                for _ in range(row_count):
                    row_data = f.read(4)
                    if len(row_data) != 4:
                        return False
                    row_numbers.append(struct.unpack('<I', row_data)[0])

                self.index_data[value] = row_numbers

        return True


class IndexManager:
    def __init__(self, table_name):
        self.table_name = table_name
        self.indexes = {}

    def create_index(self, column_name):
        if column_name not in self.indexes:
            self.indexes[column_name] = SimpleIndex(self.table_name, column_name)
        return self.indexes[column_name]

    def has_index(self, column_name):
        return column_name in self.indexes

    def get_index(self, column_name):
        return self.indexes.get(column_name)

    def update_on_insert(self, row_data, row_number):
        for column_name, index in self.indexes.items():
            if column_name in row_data:
                index.add_entry(row_data[column_name], row_number)

    def update_on_delete(self, row_data, row_number):
        for column_name, index in self.indexes.items():
            if column_name in row_data:
                index.remove_entry(row_data[column_name], row_number)

    def clear_all(self):
        for index in self.indexes.values():
            index.clear()

    def save_all(self, directory):
        for index in self.indexes.values():
            index.save_to_file(directory)

    def load_all(self, directory):
        for index in self.indexes.values():
            index.load_from_file(directory)
