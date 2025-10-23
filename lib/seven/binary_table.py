# Класс для работы с таблицей, хранящей данные в бинарном файле
# Реализует основные операции: вставка, выборка, удаление данных

import os


class BinaryTable:

    # Представляет таблицу с бинарным хранением данных в файле.
    # Каждая строка записывается последовательно в фиксированном формате.
    # Поддерживает индексы для ускорения поиска по числовым колонкам.

    def __init__(self, schema, data_directory="."):
        # schema - объект TableSchema, описывающий структуру таблицы
        # data_directory - папка для хранения файлов данных и индексов

        # Создает:
        # - Файл {table_name}.dat для хранения данных
        # - IndexManager для управления индексами
        # - Подсчитывает количество существующих строк

        self.schema = schema
        self.data_directory = data_directory
        self.data_file = os.path.join(data_directory, f"{schema.table_name}.dat")
        self.row_count = 0

        # Импорт здесь для избежания циклических зависимостей
        from indexes import IndexManager
        self.index_manager = IndexManager(schema.table_name)

        os.makedirs(data_directory, exist_ok=True)
        self._count_rows()

    def _count_rows(self):

        # Вычисляет количество строк в таблице на основе размера файла.

        # Логика:
        # - Размер файла / размер одной строки = количество строк
        # - Работает, так как все строки имеют фиксированный размер
        if os.path.exists(self.data_file):
            file_size = os.path.getsize(self.data_file)
            row_size = self.schema.get_row_size()
            if row_size > 0:
                self.row_count = file_size // row_size

    def create_index(self, column_name):
        # Создает индекс для указанной колонки.

        # Ограничения:
        # - Индексы поддерживаются только для INT колонок (8 байт)
        # - Если в таблице уже есть данные, индекс строится для всех существующих строк

        # Возвращает созданный индекс.

        column = self.schema.get_column(column_name)
        if column.get_size() != 8:  # Только для INT
            raise ValueError("Индексы поддерживаются только для INT столбцов")

        index = self.index_manager.create_index(column_name)

        # Если есть данные, строим индекс для существующих строк
        if self.row_count > 0:
            for i in range(self.row_count):
                row = self.get_row(i)
                if row and column_name in row:
                    index.add_entry(row[column_name], i)

        return index

    def insert_row(self, row_data):
        """
        Вставляет новую строку в таблицу.

        Процесс:
        1. Дополняет отсутствующие колонки значениями None
        2. Сериализует строку в байты через схему
        3. Добавляет байты в конец файла (режим 'ab' - append binary)
        4. Обновляет все индексы новой записью
        5. Увеличивает счетчик строк

        Возвращает номер вставленной строки (row_number).
        """
        # Заполняем пропущенные столбцы значениями None
        for column in self.schema.columns:
            if column.name not in row_data:
                row_data[column.name] = None

        # Преобразуем строку в байты
        serialized_row = self.schema.serialize_row(row_data)

        # Записываем в конец файла
        with open(self.data_file, 'ab') as f:
            f.write(serialized_row)

        # Обновляем индексы новой записью
        row_number = self.row_count
        self.index_manager.update_on_insert(row_data, row_number)

        self.row_count += 1
        return row_number

    def get_row(self, row_number):
        """
        Читает одну строку по её номеру.

        Процесс:
        1. Вычисляет offset = номер_строки * размер_строки
        2. Перемещается к этой позиции в файле (seek)
        3. Читает точно размер_строки байт
        4. Десериализует байты обратно в словарь

        Возвращает словарь с данными или None если строка не найдена.
        """
        if row_number < 0 or row_number >= self.row_count:
            return None

        if not os.path.exists(self.data_file):
            return None

        row_size = self.schema.get_row_size()
        offset = row_number * row_size

        with open(self.data_file, 'rb') as f:
            f.seek(offset)  # Перемещаемся к нужной позиции
            data = f.read(row_size)
            if len(data) != row_size:
                return None

            return self.schema.deserialize_row(data)

    def select_all(self):

        # Возвращает все строки таблицы.

        # Простой подход: читает все строки по порядку.
        # Для больших таблиц может быть медленным.
        result = []
        for i in range(self.row_count):
            row = self.get_row(i)
            if row:
                result.append(row)
        return result

    def select_where(self, column_name, value):

        # Выбирает строки, где указанная колонка равна заданному значению.

        # Оптимизация:
        # - Если для колонки есть индекс и это INT значение - использует индекс
        # - Иначе делает полный перебор всех строк (table scan)

        # Индекс дает значительное ускорение для больших таблиц.
        column = self.schema.get_column(column_name)
        result = []

        # Пытаемся использовать индекс для ускорения
        if (self.index_manager.has_index(column_name) and
            isinstance(value, int) and column.get_size() == 8):

            # Быстрый поиск через индекс
            index = self.index_manager.get_index(column_name)
            row_numbers = index.find_rows(value)

            for row_num in row_numbers:
                row = self.get_row(row_num)
                if row:
                    result.append(row)
        else:
            # Медленный полный перебор
            for i in range(self.row_count):
                row = self.get_row(i)
                if row and row.get(column_name) == value:
                    result.append(row)

        return result

    def delete_all(self):
        """
        Удаляет все данные из таблицы.

        Процесс:
        1. Удаляет файл данных
        2. Очищает все индексы
        3. Сбрасывает счетчик строк

        Возвращает количество удаленных строк.
        """
        deleted_count = self.row_count

        if os.path.exists(self.data_file):
            os.remove(self.data_file)

        self.index_manager.clear_all()
        self.row_count = 0
        return deleted_count

    def delete_where(self, column_name, value):
        """
        Удаляет строки, где указанная колонка равна заданному значению.

        Процесс:
        1. Находит номера строк для удаления (через индекс или полный перебор)
        2. Читает все НЕ удаляемые строки
        3. Удаляет файл данных и очищает индексы
        4. Заново вставляет оставшиеся строки

        Это простая, но неэффективная реализация. В реальных СУБД
        используются более сложные алгоритмы (например, пометка удаленных записей).

        Возвращает количество удаленных строк.
        """
        rows_to_delete = []

        # Находим строки для удаления
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

        # Читаем все строки, которые НЕ нужно удалять
        remaining_rows = []
        for i in range(self.row_count):
            if i not in rows_to_delete:
                row = self.get_row(i)
                if row:
                    remaining_rows.append(row)

        # Удаляем старый файл и очищаем индексы
        if os.path.exists(self.data_file):
            os.remove(self.data_file)

        self.index_manager.clear_all()
        self.row_count = 0

        # Заново вставляем оставшиеся строки
        for row in remaining_rows:
            self.insert_row(row)

        return len(rows_to_delete)

        return len(rows_to_delete)

    def save_indexes(self):
        self.index_manager.save_all(self.data_directory)

    def load_indexes(self):
        self.index_manager.load_all(self.data_directory)
