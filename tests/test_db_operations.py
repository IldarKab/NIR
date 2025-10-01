"""
Тесты для модуля работы с базой данных
"""
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from lib.db_context import DatabaseContext
from lib.data_saver import DataSaver
from lib.data_cleaner import DataCleaner
from lib.query_timer import QueryTimer
from lib.sandbox import SandboxManager
from investigations.config import DB_PARAMS

def test_db_context():
    print("Тестирование подключения к БД...")

    with DatabaseContext(**DB_PARAMS) as cursor:
        cursor.execute("SELECT 1")
        result = cursor.fetchone()
        assert result[0] == 1
    print("Подключение к БД работает корректно")

def test_sandbox():
    print("Тестирование песочницы...")

    sandbox = SandboxManager(DB_PARAMS)
    sandbox.create_sandbox()

    sandbox_params = sandbox.get_sandbox_params()
    with DatabaseContext(**sandbox_params) as cursor:
        cursor.execute("SELECT 1")
        result = cursor.fetchone()
        assert result[0] == 1

    sandbox.delete_sandbox()
    print("Песочница работает корректно")

def test_query_timer():
    print("Тестирование таймера запросов...")

    timer = QueryTimer(DB_PARAMS)

    time_result = timer.time_query("SELECT 1", repeat=2)
    assert time_result > 0

    def test_function():
        with DatabaseContext(**DB_PARAMS) as cursor:
            cursor.execute("SELECT 1")
            cursor.fetchone()

    time_result = timer.time_function(test_function, repeat=2)
    assert time_result > 0

    print("Таймер запросов работает корректно")

if __name__ == "__main__":
    test_db_context()
    test_sandbox()
    test_query_timer()
