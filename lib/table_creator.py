"""
Класс для создания всех таблиц базы данных AutoShipping
"""
from .db_context import DatabaseContext


class TableCreator:
    """Класс для создания всех таблиц БД"""

    def __init__(self, db_params):
        self.db_params = db_params

    def create_all_tables(self):
        """Создаёт все таблицы в базе данных"""

        # SQL для создания всех таблиц
        create_tables_sql = """
        -- Таблица клиентов
        CREATE TABLE IF NOT EXISTS clients (
            client_id SERIAL PRIMARY KEY,
            first_name VARCHAR(50) NOT NULL,
            last_name VARCHAR(50) NOT NULL,
            phone VARCHAR(20) NOT NULL,
            email VARCHAR(100) UNIQUE NOT NULL,
            passport_series VARCHAR(10) NOT NULL,
            passport_number VARCHAR(10) NOT NULL,
            registration_date DATE DEFAULT CURRENT_DATE,
            birth_date DATE NOT NULL
        );

        -- Таблица поставщиков/дилеров в Европе
        CREATE TABLE IF NOT EXISTS suppliers (
            supplier_id SERIAL PRIMARY KEY,
            company_name VARCHAR(100) NOT NULL,
            country VARCHAR(50) NOT NULL,
            city VARCHAR(50) NOT NULL,
            address TEXT NOT NULL,
            contact_person VARCHAR(100) NOT NULL,
            phone VARCHAR(20) NOT NULL,
            email VARCHAR(100) NOT NULL
        );

        -- Таблица автомобилей
        CREATE TABLE IF NOT EXISTS cars (
            car_id SERIAL PRIMARY KEY,
            vin VARCHAR(17) UNIQUE NOT NULL,
            brand VARCHAR(50) NOT NULL,
            model VARCHAR(50) NOT NULL,
            year INTEGER NOT NULL CHECK (year >= 1900 AND year <= EXTRACT(YEAR FROM CURRENT_DATE)),
            engine_volume DECIMAL(3,1) NOT NULL,
            fuel_type VARCHAR(20) NOT NULL,
            transmission VARCHAR(20) NOT NULL,
            color VARCHAR(30) NOT NULL,
            mileage INTEGER DEFAULT 0,
            price_eur DECIMAL(10,2) NOT NULL,
            supplier_id INTEGER REFERENCES suppliers(supplier_id)
        );

        -- Таблица заказов
        CREATE TABLE IF NOT EXISTS orders (
            order_id SERIAL PRIMARY KEY,
            client_id INTEGER REFERENCES clients(client_id),
            car_id INTEGER REFERENCES cars(car_id),
            order_date DATE DEFAULT CURRENT_DATE,
            expected_delivery_date DATE,
            actual_delivery_date DATE,
            total_cost_rub DECIMAL(12,2) NOT NULL,
            status VARCHAR(30) DEFAULT 'В обработке',
            customs_cleared BOOLEAN DEFAULT FALSE
        );

        -- Таблица документов клиентов (связь один к одному с клиентами)
        CREATE TABLE IF NOT EXISTS client_documents (
            document_id SERIAL PRIMARY KEY,
            client_id INTEGER UNIQUE REFERENCES clients(client_id),
            passport_scan_path VARCHAR(200),
            driver_license_path VARCHAR(200),
            additional_docs_path VARCHAR(200),
            upload_date DATE DEFAULT CURRENT_DATE
        );

        -- Таблица услуг
        CREATE TABLE IF NOT EXISTS services (
            service_id SERIAL PRIMARY KEY,
            service_name VARCHAR(100) NOT NULL,
            description TEXT,
            base_price_rub DECIMAL(10,2) NOT NULL
        );

        -- Таблица связи заказов и услуг (многие ко многим)
        CREATE TABLE IF NOT EXISTS order_services (
            order_id INTEGER REFERENCES orders(order_id),
            service_id INTEGER REFERENCES services(service_id),
            quantity INTEGER DEFAULT 1,
            price_rub DECIMAL(10,2) NOT NULL,
            PRIMARY KEY (order_id, service_id)
        );

        -- Создание индексов для оптимизации
        CREATE INDEX IF NOT EXISTS idx_orders_client_id ON orders(client_id);
        CREATE INDEX IF NOT EXISTS idx_orders_car_id ON orders(car_id);
        CREATE INDEX IF NOT EXISTS idx_cars_supplier_id ON cars(supplier_id);
        CREATE INDEX IF NOT EXISTS idx_orders_order_date ON orders(order_date);
        """

        with DatabaseContext(**self.db_params) as cursor:
            cursor.execute(create_tables_sql)
            print("Все таблицы успешно созданы!")

    def insert_basic_services(self):
        """Добавляет базовые услуги в таблицу services"""
        services_sql = """
        INSERT INTO services (service_name, description, base_price_rub) VALUES
        ('Транспортировка', 'Доставка автомобиля из Европы', 80000.00),
        ('Таможенное оформление', 'Оформление документов на таможне', 25000.00),
        ('Техосмотр', 'Проведение технического осмотра', 5000.00),
        ('Страхование', 'Страхование автомобиля при транспортировке', 15000.00),
        ('Постановка на учет', 'Регистрация в ГИБДД', 8000.00)
        ON CONFLICT DO NOTHING;
        """

        with DatabaseContext(**self.db_params) as cursor:
            cursor.execute(services_sql)
            print("Базовые услуги добавлены!")
