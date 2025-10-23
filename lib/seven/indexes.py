# Система индексов для ускорения поиска в таблицах
# Реализует простые B+ tree подобные индексы с бинарным хранением

import struct
import os
from collections import defaultdict


class SimpleIndex:
    """
    Простой индекс для числовых значений.
    Структура данных: значение -> список номеров строк

    Принцип работы:
    - Хранит отображение каждого уникального значения на список строк с этим значением
    - Позволяет быстро найти все строки с заданным значением
    - Поддерживает сохранение/загрузку в бинарном формате
    """

    def __init__(self, table_name, column_name):

        # table_name - имя таблицы (для именования файла индекса)
        # column_name - имя колонки, по которой строится индекс
        # index_data - defaultdict(list): значение -> [список номеров строк]
        self.table_name = table_name
        self.column_name = column_name
        # defaultdict автоматически создает пустой список для новых ключей
        self.index_data = defaultdict(list)

    def add_entry(self, value, row_number):
        # Добавляет запись в индекс.

        # value - значение из колонки (должно быть int)
        # row_number - номер строки в таблице

        # Пример: add_entry(42, 5) означает, что в строке №5 значение колонки равно 42

        if isinstance(value, int):
            self.index_data[value].append(row_number)

    def remove_entry(self, value, row_number):
        # Удаляет запись из индекса.

        # Если это была последняя строка с таким значением,
        # удаляет ключ полностью для экономии памяти.

        if value in self.index_data and row_number in self.index_data[value]:
            self.index_data[value].remove(row_number)
            if not self.index_data[value]:  # Если список стал пустым
                del self.index_data[value]

    def find_rows(self, value):
        # Находит все строки с заданным значением.

        # Возвращает список номеров строк или пустой список.
        # Это основная операция индекса - O(1) вместо O(n) при полном переборе.
        return self.index_data.get(value, [])

    def clear(self):
        # Очищает весь индекс.
        # Используется при удалении всех данных из таблицы.

        self.index_data.clear()

    def save_to_file(self, directory):
        """
        Сохраняет индекс в бинарный файл для персистентности.

        Формат файла:
        [4 байта] - количество уникальных значений
        Для каждого значения:
          [8 байт] - само значение (unsigned long long)
          [4 байта] - количество строк с этим значением
          [4*N байт] - номера строк (по 4 байта каждый)

        Использует little-endian формат ('<') для совместимости.
        """
        filename = f"{self.table_name}_{self.column_name}.idx"
        filepath = os.path.join(directory, filename)

        with open(filepath, 'wb') as f:
            # Записываем количество уникальных значений
            f.write(struct.pack('<I', len(self.index_data)))

            # Сортируем ключи для детерминированного порядка
            for value in sorted(self.index_data.keys()):
                row_numbers = self.index_data[value]

                # Записываем значение (8 байт)
                f.write(struct.pack('<Q', value))

                # Записываем количество строк с этим значением
                f.write(struct.pack('<I', len(row_numbers)))

                # Записываем каждый номер строки
                for row_num in row_numbers:
                    f.write(struct.pack('<I', row_num))

    def load_from_file(self, directory):
        """
        Загружает индекс из бинарного файла.

        Восстанавливает структуру index_data из сохраненного файла.
        Возвращает True при успехе, False если файл не найден или поврежден.
        """
        filename = f"{self.table_name}_{self.column_name}.idx"
        filepath = os.path.join(directory, filename)

        if not os.path.exists(filepath):
            return False

        self.index_data.clear()

        try:
            with open(filepath, 'rb') as f:
                # Читаем количество записей
                count_data = f.read(4)
                if len(count_data) != 4:
                    return False
                count = struct.unpack('<I', count_data)[0]

                # Читаем каждую запись
                for _ in range(count):
                    # Читаем значение (8 байт)
                    value_data = f.read(8)
                    if len(value_data) != 8:
                        return False
                    value = struct.unpack('<Q', value_data)[0]

                    # Читаем количество строк
                    row_count_data = f.read(4)
                    if len(row_count_data) != 4:
                        return False
                    row_count = struct.unpack('<I', row_count_data)[0]

                    # Читаем номера строк
                    row_numbers = []
                    for _ in range(row_count):
                        row_data = f.read(4)
                        if len(row_data) != 4:
                            return False
                        row_numbers.append(struct.unpack('<I', row_data)[0])

                    self.index_data[value] = row_numbers

            return True
        except Exception:
            return False


class IndexManager:
    # Управляет множественными индексами для одной таблицы.

    # Позволяет создавать индексы для разных колонок и
    # автоматически обновлять их при вставке новых данных.

    def __init__(self, table_name):

        # table_name - имя таблицы
        # indexes - словарь {имя_колонки: объект_SimpleIndex}
        self.table_name = table_name
        self.indexes = {}

    def create_index(self, column_name):
        # Создает новый индекс для указанной колонки.

        # Если индекс уже существует, возвращает существующий.
        # Это безопасная операция - можно вызывать многократно.

        if column_name not in self.indexes:
            self.indexes[column_name] = SimpleIndex(self.table_name, column_name)
        return self.indexes[column_name]

    def has_index(self, column_name):
        # Проверяет, существует ли индекс для данной колонки.
        # Используется для выбора стратегии поиска (индекс vs полный перебор).
        return column_name in self.indexes

    def get_index(self, column_name):
        # Возвращает объект индекса для колонки или None.
        return self.indexes.get(column_name)

    def update_on_insert(self, row_data, row_number):
        """
        Обновляет все индексы при вставке новой строки.

        row_data - словарь с данными вставляемой строки
        row_number - номер строки в таблице

        Проходит по всем созданным индексам и добавляет
        соответствующие записи для новой строки.
        """
        for column_name, index in self.indexes.items():
            if column_name in row_data:
                index.add_entry(row_data[column_name], row_number)

    def clear_all(self):
        # Очищает все индексы.
        # Используется при удалении всех данных из таблицы.

        for index in self.indexes.values():
            index.clear()

    def save_all(self, directory):
        # Сохраняет все индексы в файлы.
        # Каждый индекс сохраняется в отдельный .idx файл.
        for index in self.indexes.values():
            index.save_to_file(directory)

    def load_all(self, directory):
        # Загружает все индексы из файлов.
        # Восстанавливает состояние индексов после перезапуска СУБД.
        for index in self.indexes.values():
            index.load_from_file(directory)

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
