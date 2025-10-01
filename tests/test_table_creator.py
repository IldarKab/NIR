"""
Тесты для модуля создания таблиц
"""
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from lib.db_context import DatabaseContext
from lib.table_creator import TableCreator
from investigations.config import DB_PARAMS

def test_table_creation():
    print("Тестирование создания таблиц...")

    try:
        creator = TableCreator(DB_PARAMS)
        creator.create_all_tables()

        with DatabaseContext(**DB_PARAMS) as cursor:
            cursor.execute("""
                SELECT table_name FROM information_schema.tables 
                WHERE table_schema = 'public'
            """)
            tables = [row[0] for row in cursor.fetchall()]

            expected_tables = ['suppliers', 'clients', 'cars', 'orders', 'client_documents', 'services', 'order_services']
            for table in expected_tables:
                assert table in tables, f"Таблица {table} не найдена"

        creator.insert_basic_services()
        print("Создание таблиц работает корректно")

    except Exception as e:
        print(f"Ошибка при создании таблиц: {e}")
        raise

if __name__ == "__main__":
    test_table_creation()
