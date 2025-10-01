# Класс для сохранения сгенерированных данных в таблицы БД
from .db_context import DatabaseContext


class DataSaver:

    def __init__(self, db_params):
        self.db_params = db_params

    def save_clients(self, clients_data):
        sql = """
        INSERT INTO clients (first_name, last_name, phone, email, passport_series, 
                           passport_number, birth_date)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        """

        with DatabaseContext(**self.db_params) as cursor:
            for client in clients_data:
                cursor.execute(sql, (
                    client['first_name'], client['last_name'], client['phone'],
                    client['email'], client['passport_series'], client['passport_number'],
                    client['birth_date']
                ))

        print(f"Сохранено {len(clients_data)} клиентов")

    def save_suppliers(self, suppliers_data):
        sql = """
        INSERT INTO suppliers (company_name, country, city, address, contact_person, 
                             phone, email)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        """

        with DatabaseContext(**self.db_params) as cursor:
            for supplier in suppliers_data:
                cursor.execute(sql, (
                    supplier['company_name'], supplier['country'], supplier['city'],
                    supplier['address'], supplier['contact_person'], supplier['phone'],
                    supplier['email']
                ))

        print(f"Сохранено {len(suppliers_data)} поставщиков")

    def save_cars(self, cars_data):
        sql = """
        INSERT INTO cars (vin, brand, model, year, engine_volume, fuel_type, 
                         transmission, color, mileage, price_eur, supplier_id)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """

        with DatabaseContext(**self.db_params) as cursor:
            for car in cars_data:
                cursor.execute(sql, (
                    car['vin'], car['brand'], car['model'], car['year'],
                    car['engine_volume'], car['fuel_type'], car['transmission'],
                    car['color'], car['mileage'], car['price_eur'], car['supplier_id']
                ))

        print(f"Сохранено {len(cars_data)} автомобилей")

    def save_orders(self, orders_data):
        sql = """
        INSERT INTO orders (client_id, car_id, order_date, expected_delivery_date,
                           actual_delivery_date, total_cost_rub, status, customs_cleared)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """

        with DatabaseContext(**self.db_params) as cursor:
            for order in orders_data:
                cursor.execute(sql, (
                    order['client_id'], order['car_id'], order['order_date'],
                    order['expected_delivery_date'], order['actual_delivery_date'],
                    order['total_cost_rub'], order['status'], order['customs_cleared']
                ))

        print(f"Сохранено {len(orders_data)} заказов")

    def save_client_documents(self, documents_data):
        sql = """
        INSERT INTO client_documents (client_id, passport_scan_path, driver_license_path,
                                    additional_docs_path, upload_date)
        VALUES (%s, %s, %s, %s, %s)
        """

        with DatabaseContext(**self.db_params) as cursor:
            for doc in documents_data:
                cursor.execute(sql, (
                    doc['client_id'], doc['passport_scan_path'], doc['driver_license_path'],
                    doc['additional_docs_path'], doc['upload_date']
                ))

        print(f"Сохранено {len(documents_data)} документов")

    def save_order_services(self, order_services_data):
        sql = """
        INSERT INTO order_services (order_id, service_id, quantity, price_rub)
        VALUES (%s, %s, %s, %s)
        """

        with DatabaseContext(**self.db_params) as cursor:
            for order_service in order_services_data:
                cursor.execute(sql, (
                    order_service['order_id'], order_service['service_id'],
                    order_service['quantity'], order_service['price_rub']
                ))

        print(f"Сохранено {len(order_services_data)} связей заказ-услуга")
    # Получает список ID из указанной таблицы
    def get_table_ids(self, table_name, id_column):
        sql = f"SELECT {id_column} FROM {table_name}"

        with DatabaseContext(**self.db_params) as cursor:
            cursor.execute(sql)
            return [row[0] for row in cursor.fetchall()]
