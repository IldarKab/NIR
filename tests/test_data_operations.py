import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from lib.data_saver import DataSaver
from lib.data_generator import DataGenerator
from lib.table_creator import TableCreator
from lib.sandbox import SandboxManager
from investigations.config import DB_PARAMS

def test_data_saver():
    print("Тестирование сохранения данных...")

    sandbox = SandboxManager(DB_PARAMS)
    sandbox.create_sandbox()
    sandbox_params = sandbox.get_sandbox_params()

    try:
        creator = TableCreator(sandbox_params)
        creator.create_all_tables()
        creator.insert_basic_services()

        generator = DataGenerator()
        saver = DataSaver(sandbox_params)

        clients = generator.generate_clients(5)
        saver.save_clients(clients)

        suppliers = generator.generate_suppliers(3)
        saver.save_suppliers(suppliers)

        supplier_ids = saver.get_table_ids('suppliers', 'supplier_id')
        cars = generator.generate_cars(8, supplier_ids)
        saver.save_cars(cars)

        client_ids = saver.get_table_ids('clients', 'client_id')
        car_ids = saver.get_table_ids('cars', 'car_id')
        orders = generator.generate_orders(10, client_ids, car_ids)
        saver.save_orders(orders)

        print("Сохранение данных работает корректно")

    finally:
        sandbox.delete_sandbox()

def test_data_cleaner():
    print("Тестирование очистки данных...")

    sandbox = SandboxManager(DB_PARAMS)
    sandbox.create_sandbox()
    sandbox_params = sandbox.get_sandbox_params()

    try:
        from lib.data_cleaner import DataCleaner

        creator = TableCreator(sandbox_params)
        creator.create_all_tables()

        generator = DataGenerator()
        saver = DataSaver(sandbox_params)
        cleaner = DataCleaner(sandbox_params)

        clients = generator.generate_clients(5)
        saver.save_clients(clients)

        client_ids_before = saver.get_table_ids('clients', 'client_id')

        cleaner.clear_table('clients')

        client_ids_after = saver.get_table_ids('clients', 'client_id')

        if len(client_ids_after) > 0:
            raise AssertionError("Таблица clients не была очищена")

        print("Очистка данных работает корректно")

    finally:
        sandbox.delete_sandbox()
