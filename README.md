# AutoShipping Database Project

Учебный проект по разработке системы управления базами данных для компании AutoShipping, занимающейся ввозом автомобилей из Европы для российских клиентов.

## Структура проекта

### Папка `lib/` - Пункт 4: Вспомогательные функции/классы

- **table_creator.py** - Создание всех таблиц БД
- **data_generator.py** - Генерация n строк данных для таблиц с учетом ограничений предметной области
- **sandbox.py** - Создание "песочницы" - копии БД для исследований
- **data_saver.py** - Сохранение сгенерированных данных в таблицы
- **data_cleaner.py** - Удаление/замена всех данных из таблиц
- **backup_manager.py** - Бэкап и восстановление данных
- **query_timer.py** - Измерение времени выполнения запросов с использованием timeit
- **plotter.py** - Построение графиков с matplotlib
- **db_context.py** - Контекстный менеджер для автоматического коммита/закрытия соединений

### Папка `investigations/` - Пункт 5: Исследования

- **run_investigations.py** - Главный файл для запуска всех исследований
- **data_generation_research.py** - Исследование времени генерации данных для всех таблиц
- **query_performance_research.py** - Исследование времени выполнения SELECT, INSERT, DELETE запросов
- **config.py** - Конфигурация для быстрого изменения параметров исследований

### Папка `investigations/` - Пункт 6: Исследование эффективности индексов

- **index_efficiency_research.py** - Полное исследование эффективности индексов:
  - Числовые индексы (PRIMARY KEY): SELECT по равенству/неравенству, INSERT
  - Строковые индексы: SELECT с точным совпадением, LIKE по началу, LIKE в любой позиции, INSERT
  - Полнотекстовые индексы: поиск одного слова, поиск нескольких слов

### Папка `lib/seven/` - Пункт 7: Собственная СУБД

- **data_types.py** - Типы данных (INT, VARCHAR)
- **table_schema.py** - Схема таблиц в отдельных файлах
- **binary_table.py** - Хранение данных в двоичном виде
- **indexes.py** - Реализация индексов на числовые столбцы
- **sql_parser.py** - Парсер SQL запросов (CREATE TABLE, SELECT, INSERT, DELETE)
- **my_dbms.py** - Основная СУБД
- **demo.py** - Демонстрация работы СУБД

### Папка `tests/` - Пункт 3: Тесты

- **test_table_creator.py** - Тесты создания таблиц
- **test_data_generator.py** - Тесты генерации данных
- **test_db_operations.py** - Тесты операций с БД
- **test_data_operations.py** - Тесты операций с данными
- **test_utils.py** - Утилитарные тесты
- **run_all_tests.py** - Запуск всех тестов

## База данных AutoShipping

### Таблицы и связи:

1. **suppliers** (поставщики) - основная таблица
2. **clients** (клиенты) - основная таблица  
3. **cars** (автомобили) - связь "многие к одному" с suppliers
4. **orders** (заказы) - связь "многие к одному" с clients и cars
5. **client_documents** (документы клиентов) - связь "один к одному" с clients
6. **services** (услуги) - справочная таблица
7. **order_services** (услуги заказов) - связь "многие ко многим" между orders и services

### Типы данных:
- **Числа**: ID полей, цены, годы, объемы двигателей
- **Строки**: названия, адреса, ФИО, VIN номера  
- **Даты**: даты заказов, рождения, регистрации

## Как запустить

### 1. Установка зависимостей:
```bash
pip install -r requirements.txt
```

### 2. Создание и заполнение БД:
```python
python -c "
from lib.table_creator import TableCreator
from lib.data_generator import DataGenerator
from lib.data_saver import DataSaver
from lib.db_context import DatabaseContext

with DatabaseContext('AutoShipping') as conn:
    creator = TableCreator(conn)
    creator.create_all_tables()
    
generator = DataGenerator()
saver = DataSaver({'database': 'AutoShipping_db', 'host': 'localhost', 'user': 'postgres', 'password': '1234'})

# Генерация и сохранение данных
suppliers = generator.generate_suppliers(10)
saver.save_suppliers(suppliers)
"
```

### 3. Запуск исследований:
```bash
# Все исследования пунктов 5-6
python investigations/run_investigations.py

# Собственная СУБД (пункт 7)
python lib/seven/demo.py
```

### 4. Запуск тестов:
```bash
python tests/run_all_tests.py
```

## Результаты исследований

Все графики сохраняются в:
- `investigations/results/` - графики пунктов 5-6
- `seven_results/` - графики пункта 7

## Кэш и временные файлы

Кэш-файлы (`.DS_Store`, `__pycache__`) не хранятся в репозитории. Рекомендуется добавить их в `.gitignore`.

