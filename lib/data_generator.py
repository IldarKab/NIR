# Класс для генерации данных для всех таблиц
import random
import string
from datetime import datetime, timedelta
from decimal import Decimal

class DataGenerator:
    def __init__(self):
        # cписки для генерации реалистичных данных
        self.first_names = ['Александр', 'Елена', 'Дмитрий', 'Анна', 'Михаил', 'Ольга', 'Сергей',
                           'Татьяна', 'Владимир', 'Наталья', 'Алексей', 'Ирина', 'Игорь', 'Марина']

        self.last_names = ['Иванов', 'Петров', 'Сидоров', 'Козлов', 'Волков', 'Морозов', 'Лебедев',
                          'Смирнов', 'Кузнецов', 'Попов', 'Соколов', 'Михайлов', 'Новиков', 'Фёдоров']

        self.car_brands = ['BMW', 'Audi', 'Mercedes-Benz', 'Volkswagen', 'Porsche', 'Opel', 'Ford', 'Renault']

        self.car_models = {
            'BMW': ['320d', 'X3', '520d', 'X5', '730d'],
            'Audi': ['A4', 'Q5', 'A6', 'Q7', 'A3'],
            'Mercedes-Benz': ['C-Class', 'E-Class', 'GLC', 'S-Class', 'A-Class'],
            'Volkswagen': ['Passat', 'Golf', 'Tiguan', 'Touareg', 'Polo'],
            'Porsche': ['911', 'Cayenne', 'Macan', 'Panamera', 'Boxster']
        }

        self.colors = ['Черный', 'Белый', 'Серый', 'Серебристый', 'Синий', 'Красный', 'Зеленый', 'Коричневый']

        self.fuel_types = ['Бензин', 'Дизель', 'Гибрид', 'Электро']

        self.transmissions = ['Механика', 'Автомат', 'Вариатор', 'Робот']

        self.countries = ['Германия', 'Франция', 'Италия', 'Испания', 'Нидерланды', 'Бельгия', 'Австрия', 'Чехия']

        self.cities = {
            'Германия': ['Мюнхен', 'Берлин', 'Гамбург', 'Штутгарт', 'Франкфурт'],
            'Франция': ['Париж', 'Лион', 'Марсель', 'Тулуза', 'Ницца'],
            'Италия': ['Рим', 'Милан', 'Неаполь', 'Турин', 'Флоренция'],
            'Испания': ['Мадрид', 'Барселона', 'Валенсия', 'Севилья', 'Бильбао']
        }

        self.order_statuses = ['В обработке', 'В пути', 'Доставлен', 'Таможенное оформление', 'Ожидает оплаты']

    def generate_clients(self, n):
        clients = []
        used_emails = set()

        for i in range(n):
            first_name = random.choice(self.first_names)
            last_name = random.choice(self.last_names)

            # уникальный email
            email = f"{first_name.lower()}.{last_name.lower()}{i+1}@email.ru"
            while email in used_emails:
                email = f"{first_name.lower()}.{last_name.lower()}{random.randint(1, 9999)}@email.ru"
            used_emails.add(email)

            # датf рождения (возраст от 18 до 70 лет)
            min_date = datetime.now() - timedelta(days=70*365)
            max_date = datetime.now() - timedelta(days=18*365)
            birth_date = min_date + timedelta(days=random.randint(0, (max_date - min_date).days))

            client = {
                'first_name': first_name,
                'last_name': last_name,
                'phone': f"+7-{random.randint(900,999)}-{random.randint(100,999)}-{random.randint(10,99)}-{random.randint(10,99)}",
                'email': email,
                'passport_series': f"{random.randint(4500, 4599)}",
                'passport_number': f"{random.randint(100000, 999999)}",
                'birth_date': birth_date.date()
            }
            clients.append(client)

        return clients

    def generate_suppliers(self, n):
        suppliers = []

        for i in range(n):
            country = random.choice(list(self.cities.keys()))
            city = random.choice(self.cities[country])

            supplier = {
                'company_name': f"{random.choice(self.car_brands)} {city} GmbH",
                'country': country,
                'city': city,
                'address': f"Street {random.randint(1, 200)}, {random.randint(10000, 99999)} {city}",
                'contact_person': f"{random.choice(self.first_names)} {random.choice(self.last_names)}",
                'phone': f"+{random.randint(30, 49)}-{random.randint(100, 999)}-{random.randint(1000000, 9999999)}",
                'email': f"sales@{city.lower()}-auto{i+1}.com"
            }
            suppliers.append(supplier)

        return suppliers

    def generate_cars(self, n, supplier_ids):
        cars = []
        used_vins = set()

        for i in range(n):
            # уникальный VIN
            vin = self._generate_vin()
            while vin in used_vins:
                vin = self._generate_vin()
            used_vins.add(vin)

            brand = random.choice(self.car_brands)
            model = random.choice(self.car_models.get(brand, ['Model']))

            car = {
                'vin': vin,
                'brand': brand,
                'model': model,
                'year': random.randint(2015, 2024),
                'engine_volume': round(random.uniform(1.0, 4.0), 1),
                'fuel_type': random.choice(self.fuel_types),
                'transmission': random.choice(self.transmissions),
                'color': random.choice(self.colors),
                'mileage': random.randint(0, 150000),
                'price_eur': round(Decimal(random.uniform(15000, 100000)), 2),
                'supplier_id': random.choice(supplier_ids)
            }
            cars.append(car)

        return cars

    def generate_orders(self, n, client_ids, car_ids):
        orders = []

        for i in range(n):
            order_date = datetime.now() - timedelta(days=random.randint(0, 365))
            expected_delivery = order_date + timedelta(days=random.randint(30, 60))

            order = {
                'client_id': random.choice(client_ids),
                'car_id': random.choice(car_ids),
                'order_date': order_date.date(),
                'expected_delivery_date': expected_delivery.date(),
                'actual_delivery_date': None if random.random() < 0.5 else expected_delivery.date(),
                'total_cost_rub': round(Decimal(random.uniform(1500000, 8000000)), 2),
                'status': random.choice(self.order_statuses),
                'customs_cleared': random.choice([True, False])
            }
            orders.append(order)

        return orders

    def generate_client_documents(self, client_ids):
        documents = []

        # Генерируем документы не для всех клиентов
        selected_clients = random.sample(client_ids, int(len(client_ids) * 0.7))

        for client_id in selected_clients:
            doc = {
                'client_id': client_id,
                'passport_scan_path': f"/docs/passports/client_{client_id}_passport.pdf",
                'driver_license_path': f"/docs/licenses/client_{client_id}_license.pdf",
                'additional_docs_path': f"/docs/additional/client_{client_id}_additional.pdf" if random.random() < 0.3 else None,
                'upload_date': datetime.now().date()
            }
            documents.append(doc)

        return documents
    # связи заказ-услуга (многие ко многим)
    def generate_order_services(self, order_ids, service_ids):
        order_services = []

        for order_id in order_ids:
            # Каждый заказ имеет от 2 до 5 услуг
            num_services = random.randint(2, min(5, len(service_ids)))
            selected_services = random.sample(service_ids, num_services)

            for service_id in selected_services:
                order_service = {
                    'order_id': order_id,
                    'service_id': service_id,
                    'quantity': random.randint(1, 2),
                    'price_rub': round(Decimal(random.uniform(5000, 120000)), 2)
                }
                order_services.append(order_service)

        return order_services

    def _generate_vin(self):
        chars = string.ascii_uppercase + string.digits
        chars = chars.replace('I', '').replace('O', '').replace('Q', '')
        return ''.join(random.choice(chars) for _ in range(17))
