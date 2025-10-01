"""
Основной файл для запуска всех тестов
"""
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from test_table_creator import test_table_creation
from test_data_generator import test_data_generation, test_data_validation
from test_db_operations import test_db_context, test_sandbox, test_query_timer
from test_data_operations import test_data_saver, test_data_cleaner
from test_utils import test_plotter, test_backup_manager

def run_all_tests():
    """Запуск всех тестов"""
    print("ЗАПУСК ВСЕХ ТЕСТОВ")
    print("-" * 30)

    tests = [
        ("Подключение к БД", test_db_context),
        ("Создание таблиц", test_table_creation),
        ("Генерация данных", test_data_generation),
        ("Валидация данных", test_data_validation),
        ("Сохранение данных", test_data_saver),
        ("Очистка данных", test_data_cleaner),
        ("Построение графиков", test_plotter),
        ("Резервные копии", test_backup_manager),
        ("Песочница", test_sandbox),
        ("Таймер запросов", test_query_timer),
    ]

    passed = 0
    failed = 0

    for i, (test_name, test_func) in enumerate(tests, 1):
        print(f"\n{i}. {test_name}:")
        try:
            test_func()
            print("ПРОЙДЕН")
            passed += 1
        except Exception as e:
            print(f"ПРОВАЛЕН: {e}")
            failed += 1

    print(f"\nРезультат: {passed} пройдено, {failed} провалено")

if __name__ == "__main__":
    run_all_tests()
