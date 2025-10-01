"""
Тесты для модуля генерации данных
"""
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from lib.data_generator import DataGenerator

def test_data_generation():
    print("Тестирование генерации данных...")

    generator = DataGenerator()

    suppliers = generator.generate_suppliers(5)
    assert len(suppliers) == 5
    assert 'company_name' in suppliers[0]

    clients = generator.generate_clients(3)
    assert len(clients) == 3
    assert 'first_name' in clients[0]

    supplier_ids = list(range(1, len(suppliers) + 1))
    cars = generator.generate_cars(10, supplier_ids)
    assert len(cars) == 10
    assert 'vin' in cars[0]

    client_ids = list(range(1, len(clients) + 1))
    car_ids = list(range(1, len(cars) + 1))
    orders = generator.generate_orders(8, client_ids, car_ids)
    assert len(orders) == 8
    assert 'client_id' in orders[0]

    documents = generator.generate_client_documents(client_ids)
    assert len(documents) > 0

    service_ids = [1, 2, 3, 4, 5]
    order_ids = list(range(1, len(orders) + 1))
    order_services = generator.generate_order_services(order_ids, service_ids)
    assert len(order_services) > 0

    print("Генерация данных работает корректно")

def test_data_validation():
    print("Тестирование валидации данных...")

    generator = DataGenerator()

    clients = generator.generate_clients(100)
    emails = [c['email'] for c in clients]
    assert len(emails) == len(set(emails)), "Email клиентов не уникальны"

    cars = generator.generate_cars(50, [1])
    vins = [c['vin'] for c in cars]
    assert len(vins) == len(set(vins)), "VIN автомобилей не уникальны"

    print("Валидация данных прошла успешно")

if __name__ == "__main__":
    test_data_generation()
    test_data_validation()
