# конфигурация для исследований

# Параметры подключения к БД
DB_PARAMS = {
    'host': 'localhost',
    'database': 'AutoShipping_db',
    'user': 'postgres',
    'password': '1234',
    'port': 5432
}

# Параметры для песочницы
SANDBOX_PARAMS = {
    'sandbox_db_name': 'AutoShipping_db_sandbox',  # Должно совпадать с логикой SandboxManager
    'use_sandbox': True,
    'cleanup_after_test': False
}

# Параметры для исследования генерации данных
GENERATION_PARAMS = {
    # Размеры для тестирования
    'test_sizes': [10, 50, 100, 500, 1000, 2000],

    # Таблицы для исследования
    'tables': {
        'clients': 'Клиенты',
        'suppliers': 'Поставщики',
        'cars': 'Автомобили',
        'orders': 'Заказы',
        'client_documents': 'Документы клиентов',
        'order_services': 'Услуги заказов'
    }
}

# Параметры для исследования запросов
QUERY_PARAMS = {
    # Размеры для тестирования запросов
    'test_sizes': [50, 100, 200, 500, 1000],

    # Количество повторений для точности измерения
    'repeat_count': 2,

    # Запросы для каждой таблицы
    'queries': {
        'clients': {
            'SELECT все': "SELECT * FROM clients LIMIT %s",
            'SELECT с WHERE': "SELECT * FROM clients WHERE client_id <= %s",
            'INSERT': "INSERT INTO clients (first_name, last_name, phone, email, passport_series, passport_number, birth_date) VALUES (%s, %s, %s, %s, %s, %s, %s)",
            'DELETE': "DELETE FROM clients WHERE client_id <= %s"
        },
        'suppliers': {
            'SELECT все': "SELECT * FROM suppliers LIMIT %s",
            'SELECT с WHERE': "SELECT * FROM suppliers WHERE country = 'Германия' LIMIT %s",
            'INSERT': "INSERT INTO suppliers (company_name, country, city, address, contact_person, phone, email) VALUES (%s, %s, %s, %s, %s, %s, %s)",
            'DELETE': "DELETE FROM suppliers WHERE supplier_id <= %s"
        },
        'cars': {
            'SELECT все': "SELECT * FROM cars LIMIT %s",
            'SELECT с WHERE': "SELECT * FROM cars WHERE year >= 2020 LIMIT %s",
            'INSERT': "INSERT INTO cars (vin, brand, model, year, engine_volume, fuel_type, transmission, color, mileage, price_eur, supplier_id) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
            'DELETE': "DELETE FROM cars WHERE car_id <= %s"
        },
        'orders': {
            'SELECT все': "SELECT * FROM orders LIMIT %s",
            'SELECT с WHERE': "SELECT * FROM orders WHERE status = 'В обработке' LIMIT %s",
            'INSERT': "INSERT INTO orders (client_id, car_id, order_date, total_cost_rub, status) VALUES (%s, %s, %s, %s, %s)",
            'DELETE': "DELETE FROM orders WHERE order_id <= %s"
        }
    },

    # JOIN запросы для связей
    'join_queries': {
        'clients_orders': {
            'query': "SELECT c.first_name, c.last_name, o.total_cost_rub FROM clients c JOIN orders o ON c.client_id = o.client_id LIMIT %s",
            'name': 'Клиенты + Заказы'
        },
        'cars_suppliers': {
            'query': "SELECT c.brand, c.model, s.company_name FROM cars c JOIN suppliers s ON c.supplier_id = s.supplier_id LIMIT %s",
            'name': 'Автомобили + Поставщики'
        },
        'orders_cars': {
            'query': "SELECT o.order_id, c.brand, c.model, o.total_cost_rub FROM orders o JOIN cars c ON o.car_id = c.car_id LIMIT %s",
            'name': 'Заказы + Автомобили'
        },
        'orders_services': {
            'query': "SELECT o.order_id, s.service_name, os.price_rub FROM orders o JOIN order_services os ON o.order_id = os.order_id JOIN services s ON os.service_id = s.service_id LIMIT %s",
            'name': 'Заказы + Услуги'
        }
    }
}

# Параметры для графиков
PLOT_PARAMS = {
    'output_dir': 'investigations/results',
    'figure_size': (10, 6),
    'save_formats': ['png', 'svg']
}

# Параметры для исследования индексов (Пункт 6)
INDEX_PARAMS = {
    # Размеры для тестирования индексов
    'test_sizes': [100, 500, 1000, 2000, 5000],

    # Количество повторений для точности измерения
    'repeat_count': 3,

    # Параметры для пункта 6a - первичный ключ
    'primary_key': {
        'table_with_pk': 'test_clients_with_pk',
        'table_without_pk': 'test_clients_without_pk',
        'queries': {
            'select_equality': "SELECT * FROM {} WHERE client_id = {}",
            'select_inequality': "SELECT * FROM {} WHERE client_id < {}",
            'insert': "INSERT INTO {} (first_name, last_name, phone, email) VALUES (%s, %s, %s, %s)"
        }
    },

    # Параметры для пункта 6b - строковый индекс
    'string_index': {
        'table_with_index': 'test_suppliers_with_index',
        'table_without_index': 'test_suppliers_without_index',
        'indexed_column': 'company_name',
        'queries': {
            'select_equality': "SELECT * FROM {} WHERE company_name = '{}'",
            'select_like_start': "SELECT * FROM {} WHERE company_name LIKE '{}%'",
            'select_like_contains': "SELECT * FROM {} WHERE company_name LIKE '%{}%'",
            'insert': "INSERT INTO {} (company_name, country, city, contact_person) VALUES (%s, %s, %s, %s)"
        }
    },

    # Параметры для пункта 6c - полнотекстовый индекс
    'fulltext_index': {
        'table_with_index': 'test_cars_with_fulltext',
        'table_without_index': 'test_cars_without_fulltext',
        'indexed_column': 'description',
        'queries': {
            'select_single_word': "SELECT * FROM {} WHERE to_tsvector('russian', description) @@ to_tsquery('russian', 'автомобиль')",
            'select_multiple_words': "SELECT * FROM {} WHERE to_tsvector('russian', description) @@ to_tsquery('russian', 'автомобиль & двигателем')",
            'insert': "INSERT INTO {} (brand, model, description) VALUES (%s, %s, %s)"
        }
    }
}
