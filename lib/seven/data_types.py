# Система типов данных для собственной СУБД
# Определяет способы сериализации и десериализации данных в бинарный формат

import struct


class DataType:
    # Абстрактный базовый класс для всех типов данных в СУБД.
    # Определяет интерфейс для конвертации данных Python в бинарный формат и обратно.

    def serialize(self, value):
        # Преобразует Python-значение в байты для записи в файл.
        # Должен возвращать bytes фиксированной длины.
        raise NotImplementedError

    def deserialize(self, data):
        # Преобразует байты из файла обратно в Python-значение.
        # Принимает bytes, возвращает соответствующий Python-объект.

        raise NotImplementedError

    def get_size(self):
        # Возвращает количество байт, которое занимает этот тип в файле.
        # Используется для расчета смещений при чтении/записи строк.
        raise NotImplementedError


class IntType(DataType):
    # Тип данных для целых чисел.
    # Хранится как 64-битное беззнаковое число (8 байт) в little-endian формате.

    def serialize(self, value):
        # Конвертирует число в 8 байт.
        # None заменяется на 0 для простоты.
        # Использует struct.pack с форматом '<Q' (little-endian unsigned long long).
        if value is None:
            value = 0
        return struct.pack('<Q', int(value))

    def deserialize(self, data):
        # Читает 8 байт и преобразует их обратно в число.
        # Использует struct.unpack для извлечения значения.
        return struct.unpack('<Q', data)[0]

    def get_size(self):
        # INT всегда занимает 8 байт в файле.
        return 8


class VarcharType(DataType):
    # Тип данных для строк фиксированной длины.
    # Хранится в UTF-8 кодировке, дополняется null-байтами до максимальной длины.

    def __init__(self, max_length):
        # max_length - максимальная длина строки в байтах.
        # Определяет, сколько места будет зарезервировано в файле.
        self.max_length = max_length

    def serialize(self, value):
        # Конвертирует строку в байты фиксированной длины.
        # 1. Преобразует в UTF-8 байты
        # 2. Обрезает, если длиннее max_length
        # 3. Дополняет null-байтами (\x00) до max_length
        # Это обеспечивает фиксированный размер записи в файле.
        if value is None:
            value = ""
        bytes_value = str(value).encode('utf-8')
        if len(bytes_value) > self.max_length:
            bytes_value = bytes_value[:self.max_length]
        else:
            # ljust дополняет справа указанным символом до нужной длины
            bytes_value = bytes_value.ljust(self.max_length, b'\x00')
        return bytes_value

    def deserialize(self, data):
        # Читает байты из файла и преобразует обратно в строку.
        # 1. Удаляет все null-байты справа (rstrip)
        # 2. Декодирует из UTF-8 в строку
        # 3. errors='ignore' игнорирует невалидные UTF-8 последовательности
        return data.rstrip(b'\x00').decode('utf-8', errors='ignore')

    def get_size(self):
        # VARCHAR всегда занимает max_length байт в файле,
        # независимо от реальной длины строки.
        return self.max_length
