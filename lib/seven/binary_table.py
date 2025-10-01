# Таблица с двоичным хранением данных
import os


class BinaryTable:


    def __init__(self, schema, data_directory="."):
        self.schema = schema
        self.data_directory = data_directory
        self.data_file = os.path.join(data_directory, f"{schema.table_name}.dat")
        self.row_count = 0

        from indexes import IndexManager
        self.index_manager = IndexManager(schema.table_name)

        os.makedirs(data_directory, exist_ok=True)
        self._count_rows()
    # Подсчитать количество строк в файле
    def _count_rows(self):
        if os.path.exists(self.data_file):
            file_size = os.path.getsize(self.data_file)
            row_size = self.schema.get_row_size()
            if row_size > 0:
                self.row_count = file_size // row_size
    # Создать индекс на столбец
    def create_index(self, column_name):
        column = self.schema.get_column(column_name)
        if column.get_size() != 8:  # Только для INT
            raise ValueError("Индексы поддерживаются только для INT столбцов")

        index = self.index_manager.create_index(column_name)

        # Если есть данные, строим индекс
        if self.row_count > 0:
            for i in range(self.row_count):
                row = self.get_row(i)
                if row and column_name in row:
                    index.add_entry(row[column_name], i)

        return index
    # Вставить строку
    def insert_row(self, row_data):
        # Заполняем пропущенные столбцы
        for column in self.schema.columns:
            if column.name not in row_data:
                row_data[column.name] = None


        serialized_row = self.schema.serialize_row(row_data)

        with open(self.data_file, 'ab') as f:
            f.write(serialized_row)

        # Обновляем индексы
        row_number = self.row_count
        self.index_manager.update_on_insert(row_data, row_number)

        self.row_count += 1
        return row_number
    # Получить строку по номеру
    def get_row(self, row_number):
        if row_number < 0 or row_number >= self.row_count:
            return None

        if not os.path.exists(self.data_file):
            return None

        row_size = self.schema.get_row_size()
        offset = row_number * row_size

        with open(self.data_file, 'rb') as f:
            f.seek(offset)
            data = f.read(row_size)
            if len(data) != row_size:
                return None

            return self.schema.deserialize_row(data)

    def select_all(self):

        result = []
        for i in range(self.row_count):
            row = self.get_row(i)
            if row:
                result.append(row)
        return result
    # Выбрать строки по условию WHERE
    def select_where(self, column_name, value):

        column = self.schema.get_column(column_name)
        result = []

        # Используем индекс если есть и это INT
        if (self.index_manager.has_index(column_name) and
            isinstance(value, int) and column.get_size() == 8):

            index = self.index_manager.get_index(column_name)
            row_numbers = index.find_rows(value)

            for row_num in row_numbers:
                row = self.get_row(row_num)
                if row:
                    result.append(row)
        else:
            for i in range(self.row_count):
                row = self.get_row(i)
                if row and row.get(column_name) == value:
                    result.append(row)

        return result

    def delete_all(self):
        deleted_count = self.row_count

        if os.path.exists(self.data_file):
            os.remove(self.data_file)

        self.index_manager.clear_all()
        self.row_count = 0
        return deleted_count

    def delete_where(self, column_name, value):
        rows_to_delete = []

        if (self.index_manager.has_index(column_name) and isinstance(value, int)):
            index = self.index_manager.get_index(column_name)
            rows_to_delete = index.find_rows(value)
        else:
            for i in range(self.row_count):
                row = self.get_row(i)
                if row and row.get(column_name) == value:
                    rows_to_delete.append(i)

        if not rows_to_delete:
            return 0

        # Читаем оставшиеся строки
        remaining_rows = []
        for i in range(self.row_count):
            if i not in rows_to_delete:
                row = self.get_row(i)
                if row:
                    remaining_rows.append(row)

        # Перезаписываем файл
        if os.path.exists(self.data_file):
            os.remove(self.data_file)

        self.index_manager.clear_all()
        self.row_count = 0

        # Вставляем оставшиеся строки
        for row in remaining_rows:
            self.insert_row(row)

        return len(rows_to_delete)

    def save_indexes(self):
        self.index_manager.save_all(self.data_directory)

    def load_indexes(self):
        self.index_manager.load_all(self.data_directory)
