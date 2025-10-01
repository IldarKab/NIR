# типы данных для сериализации и десериализации
import struct


class DataType:

    def serialize(self, value):
        raise NotImplementedError

    def deserialize(self, data):
        raise NotImplementedError

    def get_size(self):
        raise NotImplementedError


class IntType(DataType):

    def serialize(self, value):
        if value is None:
            value = 0
        return struct.pack('<Q', int(value))

    def deserialize(self, data):
        return struct.unpack('<Q', data)[0]

    def get_size(self):
        return 8


class VarcharType(DataType):

    def __init__(self, max_length):
        self.max_length = max_length

    def serialize(self, value):
        if value is None:
            value = ""
        bytes_value = str(value).encode('utf-8')
        if len(bytes_value) > self.max_length:
            bytes_value = bytes_value[:self.max_length]
        else:
            bytes_value = bytes_value.ljust(self.max_length, b'\x00')
        return bytes_value

    def deserialize(self, data):
        return data.rstrip(b'\x00').decode('utf-8', errors='ignore')

    def get_size(self):
        return self.max_length
