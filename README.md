# AutoShipping Database Project

Учебный проект по разработке системы управления базами данных для компании AutoShipping, занимающейся ввозом автомобилей из Европы для российских клиентов.

## Структура проекта

### Папка `lib/` - Пункт 4: Вспомогательные функции/классы

- **4a_table_creator.py** - Создание всех таблиц БД
- **4b_data_generator.py** - Генерация n строк данных для таблиц с учетом ограничений предметной области
- **4c_sandbox.py** - Создание "песочницы" - копии БД для исследований
- **4d_data_saver.py** - Сохранение сгенерированных данных в таблицы
- **4e_data_cleaner.py** - Удаление/замена всех данных из таблиц
- **4f_backup_manager.py** - Бэкап и восстановление данных
- **4h_query_timer.py** - Измерение времени выполнения запросов с использованием timeit
- **4i_simple_plotter.py** - Построение графиков с matplotlib (с разными цветами, линиями, маркерами, легендой)
- **db_context.py** - Контекстный менеджер для автоматического коммита/закрытия соединений

### Папка `investigations/` - Пункт 5: Исследования

- **5_run_all_investigations.py** - Главный файл для запуска всех исследований
- **5b_data_generation_research.py** - Исследование времени генерации данных для всех таблиц
- **5c_query_performance_research.py** - Исследование времени выполнения SELECT, INSERT, DELETE запросов
- **config.py** - Конфигурация для быстрого изменения параметров исследований

### Папка `investigations/` - Пункт 6: Исследование эффективности индексов

- **6_comprehensive_index_research.py** - Полное исследование эффективности индексов:
  - **Пункт a)** Числовые индексы (PRIMARY KEY): SELECT по равенству/неравенству, INSERT
  - **Пункт b)** Строковые индексы: SELECT с точным совпадением, LIKE по началу, LIKE в любой позиции, INSERT
  - **Пункт c)** Полнотекстовые индексы: поиск одного слова, поиск нескольких слов

### Папка `seven/` - Пункт 7: Собственная СУБД

- **7_data_types.py** - Типы данных (INT, VARCHAR)
- **7_schema.py** - Схема таблиц в отдельных файлах
- **7_table.py** - Хранение данных в двоичном виде
- **7_indexes.py** - Реализация индексов на числовые столбцы
- **7_sql_parser.py** - Парсер SQL запросов (CREATE TABLE, SELECT, INSERT, DELETE)
- **7_dbms.py** - Основная СУБД
- **7_performance_research.py** - Исследование производительности собственной СУБД
- **7_demo.py** - Демонстрация работы СУБД
- **7_main.py** - Главный файл для запуска

### Папка `tests/` - Пункт 3: Тесты

- **test_table_creator.py** - Тесты создания таблиц
- **test_data_generator.py** - Тесты генерации данных
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
from lib.4a_table_creator import TableCreator
from lib.4b_data_generator import DataGenerator
from lib.4d_data_saver import DataSaver
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
python investigations/5_run_all_investigations.py

# Собственная СУБД (пункт 7)
python seven/7_main.py
```

### 4. Запуск тестов:
```bash
python tests/run_all_tests.py
```

## Результаты исследований

Все графики сохраняются в:
- `investigations/results/` - графики пунктов 5-6
- `seven_results/` - графики пункта 7

## Особенности реализации

1. **Простота и понятность** - весь код написан максимально просто для объяснения преподавателю
2. **Автоматическое управление соединениями** - все классы используют контекстные менеджеры
3. **Гибкая конфигурация** - параметры исследований легко менять в `config.py`
4. **Полное покрытие задания** - реализованы все пункты от 4 до 7
5. **Корректная нумерация файлов** - каждый файл имеет префикс с номером пункта задания
