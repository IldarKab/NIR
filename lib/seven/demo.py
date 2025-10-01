# демо
import os
import timeit
import matplotlib.pyplot as plt
import shutil


def demo_basic_operations():
    print("=== Демонстрация собственной СУБД ===")

    from my_dbms import MyDBMS

    # Создаем СУБД
    db = MyDBMS("demo_db")

    print("\n1. Создание таблиц...")

    # Создаем таблицу пользователей
    result = db.execute_sql("""
        CREATE TABLE users (
            id INT,
            name VARCHAR(50),
            age INT
        )
    """)
    print(f"  {result}")

    # Создаем таблицу товаров
    result = db.execute_sql("""
        CREATE TABLE products (
            product_id INT,
            title VARCHAR(100),
            price INT
        )
    """)
    print(f"  {result}")

    print("\n2. Вставка данных...")

    # Вставляем пользователей
    users_data = [
        (1, "Иван Петров", 25),
        (2, "Мария Сидорова", 30),
        (3, "Алексей Иванов", 22),
        (4, "Елена Козлова", 28),
        (5, "Дмитрий Смирнов", 35)
    ]

    for user_id, name, age in users_data:
        result = db.execute_sql(f'INSERT INTO users (id, name, age) VALUES ({user_id}, "{name}", {age})')
        print(f"  {result}")

    # Вставляем товары
    products_data = [
        (1, "Ноутбук", 50000),
        (2, "Мышь", 1500),
        (3, "Клавиатура", 3000),
        (4, "Монитор", 20000),
        (5, "Принтер", 15000)
    ]

    for prod_id, title, price in products_data:
        result = db.execute_sql(f'INSERT INTO products (product_id, title, price) VALUES ({prod_id}, "{title}", {price})')
        print(f"  {result}")

    print("\n3. Создание индексов...")

    # Создаем индексы на числовые столбцы
    result = db.execute_sql("CREATE INDEX ON users (id)")
    print(f"  {result}")

    result = db.execute_sql("CREATE INDEX ON products (price)")
    print(f"  {result}")

    print("\n4. Выборка данных...")

    # SELECT *
    print("  SELECT * FROM users:")
    results = db.execute_sql("SELECT * FROM users")
    for row in results:
        print(f"    {row}")

    # SELECT с выбором столбцов
    print("\n  SELECT name, age FROM users:")
    results = db.execute_sql("SELECT name, age FROM users")
    for row in results:
        print(f"    {row}")

    # SELECT с WHERE по числовому столбцу (с индексом)
    print("\n  SELECT * FROM users WHERE id = 3:")
    results = db.execute_sql("SELECT * FROM users WHERE id = 3")
    for row in results:
        print(f"    {row}")

    # SELECT с WHERE по строковому столбцу
    print('\n  SELECT * FROM users WHERE name = "Мария Сидорова":')
    results = db.execute_sql('SELECT * FROM users WHERE name = "Мария Сидорова"')
    for row in results:
        print(f"    {row}")

    print("\n5. Удаление данных...")

    # DELETE с WHERE
    result = db.execute_sql("DELETE FROM users WHERE id = 5")
    print(f"  {result}")

    print("  Пользователи после удаления:")
    results = db.execute_sql("SELECT * FROM users")
    for row in results:
        print(f"    {row}")

    print("\n6. Информация о таблицах...")

    # Информация о таблице
    info = db.get_table_info("users")
    print(f"  Таблица users:")
    print(f"    Строк: {info['row_count']}")
    print(f"    Размер строки: {info['row_size_bytes']} байт")
    print(f"    Индексы: {info['indexes']}")
    print(f"    Столбцы:")
    for col in info['columns']:
        print(f"      {col['name']}: {col['type']} ({col['size_bytes']} байт)")

    print(f"\n  Все таблицы: {db.list_tables()}")

    print("\n=== Демонстрация завершена ===")


def performance_research():
    print("\n=== Исследование производительности ===")

    from my_dbms import MyDBMS

    # Создаем отдельную СУБД для тестов
    db = MyDBMS("perf_test_db")

    # Размеры для тестирования
    test_sizes = [100, 500, 1000, 2000, 5000]

    print("\nСоздаем тестовые таблицы...")

    # Таблица с индексом
    db.execute_sql("""
        CREATE TABLE test_with_index (
            id INT,
            value INT,
            name VARCHAR(50)
        )
    """)

    # Таблица без индекса
    db.execute_sql("""
        CREATE TABLE test_without_index (
            id INT,
            value INT,
            name VARCHAR(50)
        )
    """)

    # Создаем индекс только на первой таблице
    db.execute_sql("CREATE INDEX ON test_with_index (id)")

    # Результаты тестов
    insert_times = []
    select_numeric_with_index = []
    select_numeric_without_index = []
    select_string_times = []
    delete_numeric_with_index = []
    delete_numeric_without_index = []
    delete_string_times = []

    print("Проводим тесты производительности...")

    for size in test_sizes:
        print(f"\nТестирование для {size} записей...")

        # Очищаем таблицы
        db.execute_sql("DELETE * FROM test_with_index")
        db.execute_sql("DELETE * FROM test_without_index")

        # 1. Тест INSERT
        def test_insert():
            for i in range(size):
                db.execute_sql(f'INSERT INTO test_with_index (id, value, name) VALUES ({i}, {i*10}, "Name_{i}")')
                db.execute_sql(f'INSERT INTO test_without_index (id, value, name) VALUES ({i}, {i*10}, "Name_{i}")')

        insert_time = timeit.timeit(test_insert, number=1)
        insert_times.append(insert_time)
        print(f"  INSERT: {insert_time:.4f} сек")

        # 2. Тест SELECT WHERE для числового столбца (с индексом)
        def test_select_numeric_with_index():
            for i in range(0, min(size, 100), 10):
                db.execute_sql(f"SELECT * FROM test_with_index WHERE id = {i}")

        select_time = timeit.timeit(test_select_numeric_with_index, number=1)
        select_numeric_with_index.append(select_time)
        print(f"  SELECT числовой (с индексом): {select_time:.4f} сек")

        # 3. Тест SELECT WHERE для числового столбца (без индекса)
        def test_select_numeric_without_index():
            for i in range(0, min(size, 100), 10):
                db.execute_sql(f"SELECT * FROM test_without_index WHERE id = {i}")

        select_time = timeit.timeit(test_select_numeric_without_index, number=1)
        select_numeric_without_index.append(select_time)
        print(f"  SELECT числовой (без индекса): {select_time:.4f} сек")

        # 4. Тест SELECT WHERE для строкового столбца
        def test_select_string():
            for i in range(0, min(size, 100), 10):
                db.execute_sql(f'SELECT * FROM test_with_index WHERE name = "Name_{i}"')

        select_time = timeit.timeit(test_select_string, number=1)
        select_string_times.append(select_time)
        print(f"  SELECT строковый: {select_time:.4f} сек")

        # Восстанавливаем данные для DELETE тестов
        db.execute_sql("DELETE * FROM test_with_index")
        db.execute_sql("DELETE * FROM test_without_index")
        for i in range(size):
            db.execute_sql(f'INSERT INTO test_with_index (id, value, name) VALUES ({i}, {i*10}, "Name_{i}")')
            db.execute_sql(f'INSERT INTO test_without_index (id, value, name) VALUES ({i}, {i*10}, "Name_{i}")')

        # 5. Тест DELETE WHERE для числового столбца (с индексом)
        def test_delete_numeric_with_index():
            for i in range(0, min(size, 100), 20):
                db.execute_sql(f"DELETE FROM test_with_index WHERE id = {i}")

        delete_time = timeit.timeit(test_delete_numeric_with_index, number=1)
        delete_numeric_with_index.append(delete_time)
        print(f"  DELETE числовой (с индексом): {delete_time:.4f} сек")

        # 6. Тест DELETE WHERE для числового столбца (без индекса)
        def test_delete_numeric_without_index():
            for i in range(0, min(size, 100), 20):
                db.execute_sql(f"DELETE FROM test_without_index WHERE id = {i}")

        delete_time = timeit.timeit(test_delete_numeric_without_index, number=1)
        delete_numeric_without_index.append(delete_time)
        print(f"  DELETE числовой (без индекса): {delete_time:.4f} сек")

        # Восстанавливаем данные для строкового DELETE
        db.execute_sql("DELETE * FROM test_with_index")
        for i in range(size):
            db.execute_sql(f'INSERT INTO test_with_index (id, value, name) VALUES ({i}, {i*10}, "Name_{i}")')

        # 7. Тест DELETE WHERE для строкового столбца
        def test_delete_string():
            for i in range(0, min(size, 100), 20):
                db.execute_sql(f'DELETE FROM test_with_index WHERE name = "Name_{i}"')

        delete_time = timeit.timeit(test_delete_string, number=1)
        delete_string_times.append(delete_time)
        print(f"  DELETE строковый: {delete_time:.4f} сек")

    # Создаем графики
    print("\nСоздаем графики...")
    os.makedirs("seven_results", exist_ok=True)

    # График 1: INSERT
    plt.figure(figsize=(10, 6))
    plt.plot(test_sizes, insert_times, 'b-o', linewidth=2, markersize=8, label='INSERT')
    plt.title('Производительность INSERT', fontsize=14, fontweight='bold')
    plt.xlabel('Количество записей', fontsize=12)
    plt.ylabel('Время (сек)', fontsize=12)
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('seven_results/insert_performance.png', dpi=300, bbox_inches='tight')
    plt.savefig('seven_results/insert_performance.svg', bbox_inches='tight')
    plt.close()

    # График 2: SELECT для числового столбца
    plt.figure(figsize=(10, 6))
    plt.plot(test_sizes, select_numeric_with_index, 'g-o', linewidth=2, markersize=8, label='С индексом')
    plt.plot(test_sizes, select_numeric_without_index, 'r--s', linewidth=2, markersize=8, label='Без индекса')
    plt.title('Производительность SELECT WHERE (числовой столбец)', fontsize=14, fontweight='bold')
    plt.xlabel('Количество записей', fontsize=12)
    plt.ylabel('Время (сек)', fontsize=12)
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('seven_results/select_numeric_performance.png', dpi=300, bbox_inches='tight')
    plt.savefig('seven_results/select_numeric_performance.svg', bbox_inches='tight')
    plt.close()

    # График 3: SELECT для строкового столбца
    plt.figure(figsize=(10, 6))
    plt.plot(test_sizes, select_string_times, 'm-^', linewidth=2, markersize=8, label='SELECT по строке')
    plt.title('Производительность SELECT WHERE (строковый столбец)', fontsize=14, fontweight='bold')
    plt.xlabel('Количество записей', fontsize=12)
    plt.ylabel('Время (сек)', fontsize=12)
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('seven_results/select_string_performance.png', dpi=300, bbox_inches='tight')
    plt.savefig('seven_results/select_string_performance.svg', bbox_inches='tight')
    plt.close()

    # График 4: DELETE для числового столбца
    plt.figure(figsize=(10, 6))
    plt.plot(test_sizes, delete_numeric_with_index, 'g-o', linewidth=2, markersize=8, label='С индексом')
    plt.plot(test_sizes, delete_numeric_without_index, 'r--s', linewidth=2, markersize=8, label='Без индекса')
    plt.title('Производительность DELETE WHERE (числовой столбец)', fontsize=14, fontweight='bold')
    plt.xlabel('Количество записей', fontsize=12)
    plt.ylabel('Время (сек)', fontsize=12)
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('seven_results/delete_numeric_performance.png', dpi=300, bbox_inches='tight')
    plt.savefig('seven_results/delete_numeric_performance.svg', bbox_inches='tight')
    plt.close()

    # График 5: DELETE для строкового столбца
    plt.figure(figsize=(10, 6))
    plt.plot(test_sizes, delete_string_times, 'm-^', linewidth=2, markersize=8, label='DELETE по строке')
    plt.title('Производительность DELETE WHERE (строковый столбец)', fontsize=14, fontweight='bold')
    plt.xlabel('Количество записей', fontsize=12)
    plt.ylabel('Время (сек)', fontsize=12)
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('seven_results/delete_string_performance.png', dpi=300, bbox_inches='tight')
    plt.savefig('seven_results/delete_string_performance.svg', bbox_inches='tight')
    plt.close()

    # График 6: Эффективность индексов
    plt.figure(figsize=(12, 8))
    plt.subplot(2, 1, 1)
    plt.plot(test_sizes, select_numeric_with_index, 'g-o', linewidth=2, markersize=8, label='SELECT с индексом')
    plt.plot(test_sizes, select_numeric_without_index, 'r--s', linewidth=2, markersize=8, label='SELECT без индекса')
    plt.title('Эффективность индексов для SELECT', fontsize=14, fontweight='bold')
    plt.xlabel('Количество записей', fontsize=12)
    plt.ylabel('Время (сек)', fontsize=12)
    plt.legend()
    plt.grid(True, alpha=0.3)

    plt.subplot(2, 1, 2)
    plt.plot(test_sizes, insert_times, 'b-o', linewidth=2, markersize=8, label='INSERT')
    plt.title('Производительность INSERT', fontsize=14, fontweight='bold')
    plt.xlabel('Количество записей', fontsize=12)
    plt.ylabel('Время (сек)', fontsize=12)
    plt.legend()
    plt.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('seven_results/index_efficiency_comparison.png', dpi=300, bbox_inches='tight')
    plt.savefig('seven_results/index_efficiency_comparison.svg', bbox_inches='tight')
    plt.close()

    print("Графики сохранены в папку seven_results/")

    # Выводим результаты
    print("\n=== Результаты исследования ===")
    print(f"Размеры тестов: {test_sizes}")
    print(f"INSERT (сек): {[f'{t:.4f}' for t in insert_times]}")
    print(f"SELECT числовой с индексом (сек): {[f'{t:.4f}' for t in select_numeric_with_index]}")
    print(f"SELECT числовой без индекса (сек): {[f'{t:.4f}' for t in select_numeric_without_index]}")
    print(f"SELECT строковый (сек): {[f'{t:.4f}' for t in select_string_times]}")

    # Вычисляем ускорение от индексов
    speedup = []
    for i in range(len(test_sizes)):
        if select_numeric_with_index[i] > 0:
            speedup.append(select_numeric_without_index[i] / select_numeric_with_index[i])
        else:
            speedup.append(1)

    print(f"Ускорение от индексов: {[f'{s:.2f}x' for s in speedup]}")


def main():
    # Очищаем старые данные
    for db_dir in ["demo_db", "perf_test_db"]:
        if os.path.exists(db_dir):
            shutil.rmtree(db_dir)

    os.makedirs("seven_results", exist_ok=True)

    try:
        demo_basic_operations()

        performance_research()

        print("\n=== Все тесты завершены успешно ===")

    except Exception as e:
        print(f"\nОшибка: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main()
