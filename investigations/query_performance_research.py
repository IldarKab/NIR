# Исследование времени выполнения запросов

import sys
import os

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from lib.db_context import DatabaseContext
from lib.data_generator import DataGenerator
from lib.data_saver import DataSaver
from lib.data_cleaner import DataCleaner
from lib.plotter import Plotter
from lib.query_timer import QueryTimer
from lib.sandbox import SandboxManager
from investigations.config import DB_PARAMS, PLOT_PARAMS, QUERY_PARAMS, SANDBOX_PARAMS


class QueryPerformanceInvestigator:
    def __init__(self):
        self.plotter = Plotter(PLOT_PARAMS['output_dir'])
        self.generator = DataGenerator()
        self.use_sandbox = SANDBOX_PARAMS['use_sandbox']
        self.sandbox_manager = SandboxManager(DB_PARAMS)

        db_params = self._get_db_params()
        self.timer = QueryTimer(db_params)

    def _get_db_params(self):
        if self.use_sandbox:
            params = DB_PARAMS.copy()
            params['database'] = SANDBOX_PARAMS['sandbox_db_name']
            return params
        return DB_PARAMS

    def _setup_environment(self):
        if self.use_sandbox:
            self.sandbox_manager.create_sandbox()

    def _cleanup_environment(self):
        if self.use_sandbox and SANDBOX_PARAMS['cleanup_after_test']:
            self.sandbox_manager.delete_sandbox()

    def prepare_test_data(self, max_size):
        db_params = self._get_db_params()
        self.saver = DataSaver(db_params)
        self.cleaner = DataCleaner(db_params)

        self.cleaner.clear_all_data_tables()

        from lib.table_creator import TableCreator
        creator = TableCreator(db_params)
        creator.insert_basic_services()

        clients = self.generator.generate_clients(max_size)
        self.saver.save_clients(clients)

        suppliers = self.generator.generate_suppliers(max_size//4)
        self.saver.save_suppliers(suppliers)

        supplier_ids = self.saver.get_table_ids('suppliers', 'supplier_id')
        client_ids = self.saver.get_table_ids('clients', 'client_id')

        cars = self.generator.generate_cars(max_size, supplier_ids)
        self.saver.save_cars(cars)

        car_ids = self.saver.get_table_ids('cars', 'car_id')

        orders = self.generator.generate_orders(max_size, client_ids, car_ids)
        self.saver.save_orders(orders)

        order_ids = self.saver.get_table_ids('orders', 'order_id')
        service_ids = self.saver.get_table_ids('services', 'service_id')

        documents = self.generator.generate_client_documents(client_ids[:max_size//2])
        order_services = self.generator.generate_order_services(order_ids, service_ids)

        self.saver.save_client_documents(documents)
        self.saver.save_order_services(order_services)

    def investigate_table_queries(self, table_name):
        print(f"Исследование запросов для таблицы {table_name}")

        results = {}

        for query_name, query in QUERY_PARAMS['queries'][table_name].items():
            if query_name == 'INSERT':
                continue

            results[query_name] = []

            for size in QUERY_PARAMS['test_sizes']:
                if query_name == 'DELETE':
                    time_result = self.timer.time_query(query, params=(size,), repeat=QUERY_PARAMS['repeat_count'])
                else:
                    time_result = self.timer.time_query(query, params=(size,), repeat=QUERY_PARAMS['repeat_count'])

                results[query_name].append(time_result)

        for query_name, times in results.items():
            self.plotter.create_plot(
                {f"{table_name} - {query_name}": times},
                x_values=QUERY_PARAMS['test_sizes'],
                title=f"Производительность {query_name} для таблицы {table_name}",
                x_label="Количество строк",
                y_label="Время выполнения (сек)",
                filename=f"{table_name}_{query_name.lower()}_performance"
            )

    def investigate_join_queries(self):
        print("Исследование JOIN запросов")

        join_results = {}

        for join_name, join_info in QUERY_PARAMS['join_queries'].items():
            join_results[join_info['name']] = []

            for size in QUERY_PARAMS['test_sizes']:
                time_result = self.timer.time_query(join_info['query'], params=(size,), repeat=QUERY_PARAMS['repeat_count'])
                join_results[join_info['name']].append(time_result)

        self.plotter.create_plot(
            join_results,
            x_values=QUERY_PARAMS['test_sizes'],
            title="Производительность JOIN запросов",
            x_label="Количество строк",
            y_label="Время выполнения (сек)",
            filename="join_all_queries"
        )

    def run_query_investigation(self):
        print("Исследование производительности запросов")

        try:
            self._setup_environment()

            max_test_size = max(QUERY_PARAMS['test_sizes'])
            self.prepare_test_data(max_test_size)

            # Исследуем основные таблицы
            for table_name in ['clients', 'suppliers', 'cars', 'orders']:
                self.investigate_table_queries(table_name)

            # Исследуем JOIN запросы
            self.investigate_join_queries()

            self._cleanup_environment()

            print("Исследование запросов завершено")

        except Exception as e:
            print(f"Ошибка в исследовании: {e}")
            try:
                self._cleanup_environment()
            except:
                pass


def main():
    investigator = QueryPerformanceInvestigator()
    investigator.run_query_investigation()


if __name__ == "__main__":
    main()
