# Контекстный менеджер для безопасной работы с PostgreSQL базой данных.
# Автоматически закрывает соединение и делает коммит/роллбэк.
import psycopg2
from psycopg2 import OperationalError, Error


class DatabaseContext:

    def __init__(self, host='localhost', database='AutoShipping_db', user='postgres',
                 password='1234', port=5432):
        self.connection_params = {
            'host': host,
            'database': database,
            'user': user,
            'password': password,
            'port': port
        }
        self.connection = None
        self.cursor = None
    # открываем соединение при входе в контекст
    def __enter__(self):
        try:
            self.connection = psycopg2.connect(**self.connection_params)
            self.cursor = self.connection.cursor()
            return self.cursor
        except OperationalError as e:
            print(f"Ошибка подключения к БД: {e}")
            raise
    # закрываем
    def __exit__(self, exc_type, exc_val, exc_tb):
        if self.connection:
            if exc_type is None:
                # если не было исключений - делаем коммит
                self.connection.commit()
            else:
                # если было исключение - откатываем
                self.connection.rollback()
                print(f"Ошибка в транзакции: {exc_val}")

            if self.cursor:
                self.cursor.close()
            self.connection.close()
