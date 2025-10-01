# Класс для удаления и замены данных в таблицах БД
from .db_context import DatabaseContext

class DataCleaner:
    def __init__(self, db_params):
        self.db_params = db_params
    # для указанной таблицы
    def clear_table(self, table_name):
        sql = f"TRUNCATE TABLE {table_name} CASCADE"

        with DatabaseContext(**self.db_params) as cursor:
            cursor.execute(sql)

        print(f"Таблица {table_name} очищена")
    # очищает все таблицы, кроме таблицы базовых услуг
    def clear_all_data_tables(self):
        tables_to_clear = [
            'order_services',
            'client_documents',
            'orders',
            'cars',
            'clients',
            'suppliers'
        ]

        with DatabaseContext(**self.db_params) as cursor:
            for table in tables_to_clear:
                cursor.execute(f"TRUNCATE TABLE {table} CASCADE")

        print("Все таблицы с данными очищены")
    # удаляет записи из таблицы по условию
    def delete_from_table(self, table_name, condition, params=None):
        sql = f"DELETE FROM {table_name} WHERE {condition}"

        with DatabaseContext(**self.db_params) as cursor:
            cursor.execute(sql, params or ())
            deleted_count = cursor.rowcount

        print(f"Удалено {deleted_count} записей из таблицы {table_name}")
        return deleted_count
    # Заменяет все данные в таблице на новые
    def replace_table_data(self, table_name, new_data, save_function):
        self.clear_table(table_name)
        save_function(new_data)

        print(f"Данные в таблице {table_name} заменены")
    # Возвращает количество записей в таблице
    def get_table_count(self, table_name):
        sql = f"SELECT COUNT(*) FROM {table_name}"

        with DatabaseContext(**self.db_params) as cursor:
            cursor.execute(sql)
            return cursor.fetchone()[0]
