# Исследование времени генерации данных для таблиц

import sys
import os
import timeit

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from lib.data_generator import DataGenerator
from lib.plotter import Plotter
from lib.sandbox import SandboxManager
from investigations.config import DB_PARAMS, PLOT_PARAMS, GENERATION_PARAMS, SANDBOX_PARAMS


class DataGenerationInvestigator:
    def __init__(self):
        self.generator = DataGenerator()
        self.plotter = Plotter(PLOT_PARAMS['output_dir'])
        self.use_sandbox = SANDBOX_PARAMS['use_sandbox']

        # Инициализируем sandbox_manager с правильными параметрами
        self.sandbox_manager = SandboxManager(DB_PARAMS)
        self.results = {}

    def _get_db_params(self):
        if self.use_sandbox:
            params = DB_PARAMS.copy()
            params['database'] = SANDBOX_PARAMS['sandbox_db_name']
            return params
        return DB_PARAMS

    def _setup_environment(self):
        if self.use_sandbox:
            print("Создаем песочницу для безопасного тестирования...")
            self.sandbox_manager.create_sandbox()
            print("Песочница создана успешно")

    def _cleanup_environment(self):
        if self.use_sandbox and SANDBOX_PARAMS['cleanup_after_test']:
            print("Удаляем песочницу...")
            self.sandbox_manager.delete_sandbox()
            print("Песочница удалена")

    def measure_generation_time(self, table_name, size):
        if table_name == 'clients':
            def generate():
                return self.generator.generate_clients(size)

        elif table_name == 'suppliers':
            def generate():
                return self.generator.generate_suppliers(size)

        elif table_name == 'cars':
            def generate():
                supplier_ids = list(range(1, min(size//2, 10) + 1))
                return self.generator.generate_cars(size, supplier_ids)

        elif table_name == 'orders':
            def generate():
                client_ids = list(range(1, min(size//2, 20) + 1))
                car_ids = list(range(1, min(size//2, 30) + 1))
                return self.generator.generate_orders(size, client_ids, car_ids)

        elif table_name == 'client_documents':
            def generate():
                client_ids = list(range(1, size + 1))
                return self.generator.generate_client_documents(client_ids)

        elif table_name == 'order_services':
            def generate():
                order_ids = list(range(1, min(size//3, 50) + 1))
                service_ids = list(range(1, 6))  # У нас 5 услуг
                return self.generator.generate_order_services(order_ids, service_ids)

        else:
            return 0

        time_taken = timeit.timeit(generate, number=1)
        return time_taken
    # измеряет время генерации связанных таблиц
    def measure_foreign_key_generation(self, size):
        def generate_cars_with_suppliers():
            suppliers = self.generator.generate_suppliers(size//4)
            supplier_ids = list(range(1, len(suppliers) + 1))

            cars = self.generator.generate_cars(size, supplier_ids)
            return suppliers, cars

        def generate_orders_with_clients():
            clients = self.generator.generate_clients(size//3)
            client_ids = list(range(1, len(clients) + 1))
            car_ids = list(range(1, size//2 + 1))

            orders = self.generator.generate_orders(size, client_ids, car_ids)
            return clients, orders

        # Измеряем время для связанных таблиц
        cars_suppliers_time = timeit.timeit(generate_cars_with_suppliers, number=1)
        orders_clients_time = timeit.timeit(generate_orders_with_clients, number=1)

        return {
            'cars_suppliers': cars_suppliers_time,
            'orders_clients': orders_clients_time
        }

    def run_investigation(self):
        print("Исследование времени генерации данных\n")

        sizes = GENERATION_PARAMS['test_sizes']
        tables = GENERATION_PARAMS['tables']

        # Исследуем каждую таблицу отдельно
        for table_name, table_title in tables.items():
            print(f"Исследуем таблицу: {table_title}")

            times = []
            for size in sizes:
                print(f"  Генерируем {size} записей...")
                time_taken = self.measure_generation_time(table_name, size)
                times.append(time_taken)
                print(f"    Время: {time_taken:.4f} сек")

            self.results[table_name] = times

        print("\nИсследуем связанные таблицы (FK):")

        fk_results = {
            'cars_suppliers': [],
            'orders_clients': []
        }

        for size in sizes:
            print(f"  Размер: {size}")
            fk_times = self.measure_foreign_key_generation(size)

            for relation, time_taken in fk_times.items():
                fk_results[relation].append(time_taken)
                print(f"    {relation}: {time_taken:.4f} сек")

        print("\nСоздаем графики...")

        # 1. Общий график всех таблиц
        all_data = {}
        for table_name, times in self.results.items():
            table_title = tables[table_name]
            all_data[table_title] = times

        self.plotter.create_plot(
            data=all_data,
            x_values=sizes,
            title="Время генерации данных для всех таблиц",
            x_label="Количество записей",
            y_label="Время (секунды)",
            filename="generation_all_tables"
        )

        # 2. График для связанных таблиц (FK)
        fk_data = {
            'Автомобили + Поставщики': fk_results['cars_suppliers'],
            'Заказы + Клиенты': fk_results['orders_clients']
        }

        self.plotter.create_plot(
            data=fk_data,
            x_values=sizes,
            title="Время генерации связанных таблиц (FK)",
            x_label="Количество записей",
            y_label="Время (секунды)",
            filename="generation_foreign_keys"
        )

        print(f"\n=== Исследование завершено ===")
        print(f"Графики сохранены в: {PLOT_PARAMS['output_dir']}")

        # Очищаем окружение после тестов
        self._cleanup_environment()


if __name__ == "__main__":
    investigator = DataGenerationInvestigator()
    investigator._setup_environment()
    investigator.run_investigation()
    investigator._cleanup_environment()
