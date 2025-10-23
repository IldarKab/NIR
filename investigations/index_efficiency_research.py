# Исследование эффективности использования индексов

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
from investigations.config import DB_PARAMS, PLOT_PARAMS, INDEX_PARAMS, SANDBOX_PARAMS


class IndexEfficiencyInvestigator:
    def __init__(self):
        self.plotter = Plotter(PLOT_PARAMS['output_dir'])
        self.generator = DataGenerator()
        self.use_sandbox = SANDBOX_PARAMS['use_sandbox']
        self.sandbox_manager = SandboxManager(DB_PARAMS)

        db_params = self._get_db_params()
        self.timer = QueryTimer(db_params)
        self.data_saver = DataSaver(db_params)
        self.data_cleaner = DataCleaner(db_params)

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

    def create_test_tables(self):
        create_tables_sql = """
        DROP TABLE IF EXISTS test_clients_with_pk CASCADE;
        DROP TABLE IF EXISTS test_clients_without_pk CASCADE;
        
        CREATE TABLE test_clients_with_pk (
            client_id SERIAL PRIMARY KEY,
            first_name VARCHAR(50) NOT NULL,
            last_name VARCHAR(50) NOT NULL,
            phone VARCHAR(20) NOT NULL,
            email VARCHAR(100) NOT NULL
        );
        
        CREATE TABLE test_clients_without_pk (
            client_id INTEGER NOT NULL,
            first_name VARCHAR(50) NOT NULL,
            last_name VARCHAR(50) NOT NULL,
            phone VARCHAR(20) NOT NULL,
            email VARCHAR(100) NOT NULL
        );
        
        DROP TABLE IF EXISTS test_suppliers_with_index CASCADE;
        DROP TABLE IF EXISTS test_suppliers_without_index CASCADE;
        
        CREATE TABLE test_suppliers_with_index (
            supplier_id SERIAL PRIMARY KEY,
            company_name VARCHAR(100) NOT NULL,
            country VARCHAR(50) NOT NULL,
            city VARCHAR(50) NOT NULL,
            contact_person VARCHAR(100) NOT NULL
        );
        
        CREATE TABLE test_suppliers_without_index (
            supplier_id SERIAL PRIMARY KEY,
            company_name VARCHAR(100) NOT NULL,
            country VARCHAR(50) NOT NULL,
            city VARCHAR(50) NOT NULL,
            contact_person VARCHAR(100) NOT NULL
        );
        
        CREATE INDEX idx_suppliers_company_name ON test_suppliers_with_index(company_name);
        
        DROP TABLE IF EXISTS test_cars_with_fulltext CASCADE;
        DROP TABLE IF EXISTS test_cars_without_fulltext CASCADE;
        
        CREATE TABLE test_cars_with_fulltext (
            car_id SERIAL PRIMARY KEY,
            brand VARCHAR(50) NOT NULL,
            model VARCHAR(50) NOT NULL,
            description TEXT NOT NULL
        );
        
        CREATE TABLE test_cars_without_fulltext (
            car_id SERIAL PRIMARY KEY,
            brand VARCHAR(50) NOT NULL,
            model VARCHAR(50) NOT NULL,
            description TEXT NOT NULL
        );
        
        CREATE INDEX idx_cars_description_fulltext ON test_cars_with_fulltext 
        USING gin(to_tsvector('russian', description));
        """

        db_params = self._get_db_params()
        with DatabaseContext(**db_params) as cursor:
            cursor.execute(create_tables_sql)

    def cleanup_test_tables(self):
        cleanup_sql = """
        DROP TABLE IF EXISTS test_clients_with_pk CASCADE;
        DROP TABLE IF EXISTS test_clients_without_pk CASCADE;
        DROP TABLE IF EXISTS test_suppliers_with_index CASCADE;
        DROP TABLE IF EXISTS test_suppliers_without_index CASCADE;
        DROP TABLE IF EXISTS test_cars_with_fulltext CASCADE;
        DROP TABLE IF EXISTS test_cars_without_fulltext CASCADE;
        """

        db_params = self._get_db_params()
        with DatabaseContext(**db_params) as cursor:
            cursor.execute(cleanup_sql)

    def clear_test_tables(self):
        db_params = self._get_db_params()
        with DatabaseContext(**db_params) as cursor:
            cursor.execute("""
                TRUNCATE test_clients_with_pk, test_clients_without_pk,
                         test_suppliers_with_index, test_suppliers_without_index,
                         test_cars_with_fulltext, test_cars_without_fulltext
                RESTART IDENTITY
            """)

    def populate_test_tables(self, size):
        clients_data_raw = self.generator.generate_clients(size)
        suppliers_data_raw = self.generator.generate_suppliers(size)
        cars_data_raw = self.generator.generate_cars(size, [1])

        clients_data = []
        suppliers_data = []
        cars_data = []

        for i, client_data in enumerate(clients_data_raw):
            clients_data.append((
                i + 1,
                client_data['first_name'],
                client_data['last_name'],
                client_data['phone'],
                client_data['email']
            ))

        for supplier_data in suppliers_data_raw:
            suppliers_data.append((
                supplier_data['company_name'],
                supplier_data['country'],
                supplier_data['city'],
                supplier_data['contact_person']
            ))

        for car_data in cars_data_raw:
            description = f"{car_data['brand']} {car_data['model']} автомобиль с двигателем {car_data['engine_volume']}л, {car_data['fuel_type']}, {car_data['transmission']}, цвет {car_data['color']}, пробег {car_data['mileage']} км"
            cars_data.append((
                car_data['brand'],
                car_data['model'],
                description
            ))

        db_params = self._get_db_params()
        with DatabaseContext(**db_params) as cursor:
            cursor.executemany(
                "INSERT INTO test_clients_with_pk (first_name, last_name, phone, email) VALUES (%s, %s, %s, %s)",
                [(c[1], c[2], c[3], c[4]) for c in clients_data]
            )

            cursor.executemany(
                "INSERT INTO test_clients_without_pk (client_id, first_name, last_name, phone, email) VALUES (%s, %s, %s, %s, %s)",
                clients_data
            )

            cursor.executemany(
                "INSERT INTO test_suppliers_with_index (company_name, country, city, contact_person) VALUES (%s, %s, %s, %s)",
                suppliers_data
            )

            cursor.executemany(
                "INSERT INTO test_suppliers_without_index (company_name, country, city, contact_person) VALUES (%s, %s, %s, %s)",
                suppliers_data
            )

            cursor.executemany(
                "INSERT INTO test_cars_with_fulltext (brand, model, description) VALUES (%s, %s, %s)",
                cars_data
            )

            cursor.executemany(
                "INSERT INTO test_cars_without_fulltext (brand, model, description) VALUES (%s, %s, %s)",
                cars_data
            )

    def investigate_primary_key_performance(self):
        print("Исследование производительности первичного ключа")

        select_equality_results = {'С первичным ключом': [], 'без первичного ключа': []}
        select_inequality_results = {'С первичным ключом': [], 'без первичного ключа': []}
        insert_results = {'С первичным ключом': [], 'без первичного ключа': []}

        for size in INDEX_PARAMS['test_sizes']:
            self.clear_test_tables()
            self.populate_test_tables(size)

            test_id = size // 2

            def query_equality_with_pk():
                with DatabaseContext(**self._get_db_params()) as cursor:
                    cursor.execute("SELECT * FROM test_clients_with_pk WHERE client_id = %s", (test_id,))
                    cursor.fetchall()

            def query_equality_without_pk():
                with DatabaseContext(**self._get_db_params()) as cursor:
                    cursor.execute("SELECT * FROM test_clients_without_pk WHERE client_id = %s", (test_id,))
                    cursor.fetchall()

            time_with_pk = self.timer.time_function(query_equality_with_pk, repeat=INDEX_PARAMS['repeat_count'])
            time_without_pk = self.timer.time_function(query_equality_without_pk, repeat=INDEX_PARAMS['repeat_count'])

            select_equality_results['С первичным ключом'].append(time_with_pk)
            select_equality_results['без первичного ключа'].append(time_without_pk)

            def query_inequality_with_pk():
                with DatabaseContext(**self._get_db_params()) as cursor:
                    cursor.execute("SELECT * FROM test_clients_with_pk WHERE client_id < %s", (test_id,))
                    cursor.fetchall()

            def query_inequality_without_pk():
                with DatabaseContext(**self._get_db_params()) as cursor:
                    cursor.execute("SELECT * FROM test_clients_without_pk WHERE client_id < %s", (test_id,))
                    cursor.fetchall()

            time_with_pk = self.timer.time_function(query_inequality_with_pk, repeat=INDEX_PARAMS['repeat_count'])
            time_without_pk = self.timer.time_function(query_inequality_without_pk, repeat=INDEX_PARAMS['repeat_count'])

            select_inequality_results['С первичным ключом'].append(time_with_pk)
            select_inequality_results['без первичного ключа'].append(time_without_pk)

            test_clients_data = self.generator.generate_clients(50)
            test_data = [(cd['first_name'], cd['last_name'], cd['phone'], cd['email']) for cd in test_clients_data]

            def insert_with_pk():
                db_params = self._get_db_params()
                with DatabaseContext(**db_params) as cursor:
                    cursor.executemany("INSERT INTO test_clients_with_pk (first_name, last_name, phone, email) VALUES (%s, %s, %s, %s)", test_data)

            def insert_without_pk():
                test_data_with_id = [(size + i + 1, d[0], d[1], d[2], d[3]) for i, d in enumerate(test_data)]
                db_params = self._get_db_params()
                with DatabaseContext(**db_params) as cursor:
                    cursor.executemany("INSERT INTO test_clients_without_pk (client_id, first_name, last_name, phone, email) VALUES (%s, %s, %s, %s, %s)", test_data_with_id)

            time_with_pk = self.timer.time_function(insert_with_pk, repeat=2)
            time_without_pk = self.timer.time_function(insert_without_pk, repeat=2)

            insert_results['С первичным ключом'].append(time_with_pk)
            insert_results['без первичного ключа'].append(time_without_pk)

        self.plotter.create_plot(
            select_equality_results,
            x_values=INDEX_PARAMS['test_sizes'],
            title="Производительность SELECT с условием равенства (первичный ключ)",
            x_label="Количество строк в таблице",
            y_label="Время выполнения (сек)",
            filename="6a_primary_key_select_equality"
        )

        self.plotter.create_plot(
            select_inequality_results,
            x_values=INDEX_PARAMS['test_sizes'],
            title="Производительность SELECT с условием неравенства (первичный ключ)",
            x_label="Количество строк в таблице",
            y_label="Время выполнения (сек)",
            filename="6a_primary_key_select_inequality"
        )

        self.plotter.create_plot(
            insert_results,
            x_values=INDEX_PARAMS['test_sizes'],
            title="Производительность INSERT (первичный ключ)",
            x_label="Количество строк в таблице",
            y_label="Время выполнения (сек)",
            filename="6a_primary_key_insert"
        )

    def investigate_string_index_performance(self):
        print("Исследование производительности строкового индекса")

        select_equality_results = {'С индексом': [], 'Без индекса': []}
        select_like_start_results = {'С индексом': [], 'Без индекса': []}
        select_like_contains_results = {'С индексом': [], 'Без индекса': []}
        insert_results = {'С индексом': [], 'Без индекса': []}

        for size in INDEX_PARAMS['test_sizes']:
            self.clear_test_tables()
            self.populate_test_tables(size)

            db_params = self._get_db_params()
            with DatabaseContext(**db_params) as cursor:
                cursor.execute("SELECT company_name FROM test_suppliers_with_index LIMIT 1")
                result = cursor.fetchone()
                test_name = result[0] if result else "Test Company"

            def query_equality_with_index():
                with DatabaseContext(**self._get_db_params()) as cursor:
                    cursor.execute("SELECT * FROM test_suppliers_with_index WHERE company_name = %s", (test_name,))
                    cursor.fetchall()

            def query_equality_without_index():
                with DatabaseContext(**self._get_db_params()) as cursor:
                    cursor.execute("SELECT * FROM test_suppliers_without_index WHERE company_name = %s", (test_name,))
                    cursor.fetchall()

            time_with_index = self.timer.time_function(query_equality_with_index, repeat=INDEX_PARAMS['repeat_count'])
            time_without_index = self.timer.time_function(query_equality_without_index, repeat=INDEX_PARAMS['repeat_count'])

            select_equality_results['С индексом'].append(time_with_index)
            select_equality_results['Без индекса'].append(time_without_index)

            search_prefix = test_name[:3] + '%'

            def query_like_start_with_index():
                with DatabaseContext(**self._get_db_params()) as cursor:
                    cursor.execute("SELECT * FROM test_suppliers_with_index WHERE company_name LIKE %s", (search_prefix,))
                    cursor.fetchall()

            def query_like_start_without_index():
                with DatabaseContext(**self._get_db_params()) as cursor:
                    cursor.execute("SELECT * FROM test_suppliers_without_index WHERE company_name LIKE %s", (search_prefix,))
                    cursor.fetchall()

            time_with_index = self.timer.time_function(query_like_start_with_index, repeat=INDEX_PARAMS['repeat_count'])
            time_without_index = self.timer.time_function(query_like_start_without_index, repeat=INDEX_PARAMS['repeat_count'])

            select_like_start_results['С индексом'].append(time_with_index)
            select_like_start_results['Без индекса'].append(time_without_index)

            search_substring = '%' + (test_name[2:5] if len(test_name) >= 5 else "Com") + '%'

            def query_like_contains_with_index():
                with DatabaseContext(**self._get_db_params()) as cursor:
                    cursor.execute("SELECT * FROM test_suppliers_with_index WHERE company_name LIKE %s", (search_substring,))
                    cursor.fetchall()

            def query_like_contains_without_index():
                with DatabaseContext(**self._get_db_params()) as cursor:
                    cursor.execute("SELECT * FROM test_suppliers_without_index WHERE company_name LIKE %s", (search_substring,))
                    cursor.fetchall()

            time_with_index = self.timer.time_function(query_like_contains_with_index, repeat=INDEX_PARAMS['repeat_count'])
            time_without_index = self.timer.time_function(query_like_contains_without_index, repeat=INDEX_PARAMS['repeat_count'])

            select_like_contains_results['С индексом'].append(time_with_index)
            select_like_contains_results['Без индекса'].append(time_without_index)

            test_suppliers_data = self.generator.generate_suppliers(50)
            test_data = [(sd['company_name'], sd['country'], sd['city'], sd['contact_person']) for sd in test_suppliers_data]

            def insert_with_index():
                db_params = self._get_db_params()
                with DatabaseContext(**db_params) as cursor:
                    cursor.executemany("INSERT INTO test_suppliers_with_index (company_name, country, city, contact_person) VALUES (%s, %s, %s, %s)", test_data)

            def insert_without_index():
                db_params = self._get_db_params()
                with DatabaseContext(**db_params) as cursor:
                    cursor.executemany("INSERT INTO test_suppliers_without_index (company_name, country, city, contact_person) VALUES (%s, %s, %s, %s)", test_data)

            time_with_index = self.timer.time_function(insert_with_index, repeat=2)
            time_without_index = self.timer.time_function(insert_without_index, repeat=2)

            insert_results['С индексом'].append(time_with_index)
            insert_results['Без индекса'].append(time_without_index)

        self.plotter.create_plot(
            select_equality_results,
            x_values=INDEX_PARAMS['test_sizes'],
            title="Производительность SELECT с условием равенства (строковый индекс)",
            x_label="Количество строк в таблице",
            y_label="Время выполнения (сек)",
            filename="6b_string_index_select_equality"
        )

        self.plotter.create_plot(
            select_like_start_results,
            x_values=INDEX_PARAMS['test_sizes'],
            title="Производительность SELECT с LIKE для начала строки (строковый индекс)",
            x_label="Количество строк в таблице",
            y_label="Время выполнения (сек)",
            filename="6b_string_index_select_like_start"
        )

        self.plotter.create_plot(
            select_like_contains_results,
            x_values=INDEX_PARAMS['test_sizes'],
            title="Производительность SELECT с LIKE для содержания (строковый индекс)",
            x_label="Количество строк в таблице",
            y_label="Время выполнения (сек)",
            filename="6b_string_index_select_like_contains"
        )

        self.plotter.create_plot(
            insert_results,
            x_values=INDEX_PARAMS['test_sizes'],
            title="Производительность INSERT (строковый индекс)",
            x_label="Количество строк в таблице",
            y_label="Время выполнения (сек)",
            filename="6b_string_index_insert"
        )

    def investigate_fulltext_index_performance(self):
        print("Исследование производительности полнотекстового индекса")

        select_single_word_results = {'С полнотекстовым индексом': [], 'Без индекса': []}
        select_multiple_words_results = {'С полнотекстовым индексом': [], 'Без индекса': []}
        insert_results = {'С полнотекстовым индексом': [], 'Без индекса': []}

        for size in INDEX_PARAMS['test_sizes']:
            self.clear_test_tables()
            self.populate_test_tables(size)

            def query_single_word_with_index():
                with DatabaseContext(**self._get_db_params()) as cursor:
                    cursor.execute("SELECT * FROM test_cars_with_fulltext WHERE to_tsvector('russian', description) @@ to_tsquery('russian', 'автомобиль')")
                    cursor.fetchall()

            def query_single_word_without_index():
                with DatabaseContext(**self._get_db_params()) as cursor:
                    cursor.execute("SELECT * FROM test_cars_without_fulltext WHERE to_tsvector('russian', description) @@ to_tsquery('russian', 'автомобиль')")
                    cursor.fetchall()

            time_with_index = self.timer.time_function(query_single_word_with_index, repeat=INDEX_PARAMS['repeat_count'])
            time_without_index = self.timer.time_function(query_single_word_without_index, repeat=INDEX_PARAMS['repeat_count'])

            select_single_word_results['С полнотекстовым индексом'].append(time_with_index)
            select_single_word_results['Без индекса'].append(time_without_index)

            def query_multiple_words_with_index():
                with DatabaseContext(**self._get_db_params()) as cursor:
                    cursor.execute("SELECT * FROM test_cars_with_fulltext WHERE to_tsvector('russian', description) @@ to_tsquery('russian', 'автомобиль & двигателем')")
                    cursor.fetchall()

            def query_multiple_words_without_index():
                with DatabaseContext(**self._get_db_params()) as cursor:
                    cursor.execute("SELECT * FROM test_cars_without_fulltext WHERE to_tsvector('russian', description) @@ to_tsquery('russian', 'автомобиль & двигателем')")
                    cursor.fetchall()

            time_with_index = self.timer.time_function(query_multiple_words_with_index, repeat=INDEX_PARAMS['repeat_count'])
            time_without_index = self.timer.time_function(query_multiple_words_without_index, repeat=INDEX_PARAMS['repeat_count'])

            select_multiple_words_results['С полнотекстовым индексом'].append(time_with_index)
            select_multiple_words_results['Без индекса'].append(time_without_index)

            test_cars_data = self.generator.generate_cars(50, [1])
            test_data = []
            for car_data in test_cars_data:
                description = f"{car_data['brand']} {car_data['model']} автомобиль с двигателем {car_data['engine_volume']}л, {car_data['fuel_type']}, {car_data['transmission']}, цвет {car_data['color']}, пробег {car_data['mileage']} км"
                test_data.append((car_data['brand'], car_data['model'], description))

            def insert_with_index():
                db_params = self._get_db_params()
                with DatabaseContext(**db_params) as cursor:
                    cursor.executemany("INSERT INTO test_cars_with_fulltext (brand, model, description) VALUES (%s, %s, %s)", test_data)

            def insert_without_index():
                db_params = self._get_db_params()
                with DatabaseContext(**db_params) as cursor:
                    cursor.executemany("INSERT INTO test_cars_without_fulltext (brand, model, description) VALUES (%s, %s, %s)", test_data)

            time_with_index = self.timer.time_function(insert_with_index, repeat=2)
            time_without_index = self.timer.time_function(insert_without_index, repeat=2)

            insert_results['С полнотекстовым индексом'].append(time_with_index)
            insert_results['Без индекса'].append(time_without_index)

        self.plotter.create_plot(
            select_single_word_results,
            x_values=INDEX_PARAMS['test_sizes'],
            title="Производительность полнотекстового поиска одного слова",
            x_label="Количество строк в таблице",
            y_label="Время выполнения (сек)",
            filename="6c_fulltext_index_select_single_word"
        )

        self.plotter.create_plot(
            select_multiple_words_results,
            x_values=INDEX_PARAMS['test_sizes'],
            title="Производительность полнотекстового поиска нескольких слов",
            x_label="Количество строк в таблице",
            y_label="Время выполнения (сек)",
            filename="6c_fulltext_index_select_multiple_words"
        )

        self.plotter.create_plot(
            insert_results,
            x_values=INDEX_PARAMS['test_sizes'],
            title="Производительность INSERT (полнотекстовый индекс)",
            x_label="Количество строк в таблице",
            y_label="Время выполнения (сек)",
            filename="6c_fulltext_index_insert"
        )

    def run_index_investigation(self):
        print("Исследование эффективности использования индексов (Пункт 6)")

        try:
            self._setup_environment()
            self.create_test_tables()

            self.investigate_primary_key_performance()
            self.investigate_string_index_performance()
            self.investigate_fulltext_index_performance()

            self.cleanup_test_tables()
            self._cleanup_environment()

            print("Исследования эффективности индексов завершены успешно")
            print(f"Результаты сохранены в директории: {PLOT_PARAMS['output_dir']}")

        except Exception as e:
            print(f"Ошибка в исследовании: {e}")
            try:
                self.cleanup_test_tables()
                self._cleanup_environment()
            except:
                pass


def main():
    investigator = IndexEfficiencyInvestigator()
    investigator.run_index_investigation()


if __name__ == "__main__":
    main()
