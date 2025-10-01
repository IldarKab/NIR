# Класс для измерения времени выполнения запросов к базе данных
import timeit
from timeit import repeat
from .db_context import DatabaseContext


class QueryTimer:

    def __init__(self, db_params):
        self.db_params = db_params

    # Измеряет время выполнения произвольного SQL-запроса с повторениями
    def time_query(self, query, params=None, repeat=5):
        """Измеряет время выполнения произвольного SQL-запроса с повторениями"""
        def execute_query():
            with DatabaseContext(**self.db_params) as cursor:
                cursor.execute(query, params or ())
                # Только для SELECT запросов вызываем fetchall()
                if query.strip().upper().startswith('SELECT'):
                    cursor.fetchall()

        times = timeit.repeat(execute_query, repeat=repeat, number=1)
        return sum(times) / len(times)

    # сравнивает время выполнения нескольких запросов
    def compare_queries(self, queries_dict, number=1):
        results = {}

        print("Сравнение времени выполнения запросов:")
        print()

        for name, (query, params) in queries_dict.items():
            execution_time = self.measure_query_time(query, params, number)
            results[name] = execution_time / number  # среднее время за один запрос
            print(f"{name}: {results[name]:.4f} сек")
            print("-" * 30)

        fastest = min(results, key=results.get)
        slowest = max(results, key=results.get)

        print(f"\nСамый быстрый: {fastest} ({results[fastest]:.4f} сек)")
        print(f"Самый медленный: {slowest} ({results[slowest]:.4f} сек)")

        return results
    # Измеряет время выполнения произвольной функции
    def time_function(self, func, repeat=3):
        times = timeit.repeat(func, repeat=repeat, number=1)
        return sum(times) / len(times)  # Возвращаем среднее время
