# Главный файл для запуска всех исследований

import sys
import os

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from investigations.data_generation_research import DataGenerationInvestigator
from investigations.query_performance_research import QueryPerformanceInvestigator
from investigations.index_efficiency_research import IndexEfficiencyInvestigator
from investigations.config import PLOT_PARAMS, SANDBOX_PARAMS


def main():

    os.makedirs(PLOT_PARAMS['output_dir'], exist_ok=True)

    if SANDBOX_PARAMS['use_sandbox']:
        print("Все исследования будут проводиться в безопасной песочнице")
        print(f"Песочница: {SANDBOX_PARAMS['sandbox_db_name']}")

    # 1. Исследование генерации данных
    print("\nЭТАП 1: Исследование времени генерации данных")
    print("-" * 50)
    try:
        gen_investigator = DataGenerationInvestigator()
        gen_investigator._setup_environment()
        gen_investigator.run_investigation()
        gen_investigator._cleanup_environment()
        print("Исследование генерации данных завершено успешно!")
    except Exception as e:
        print(f"Ошибка в исследовании генерации: {e}")

    # 2. Исследование производительности запросов
    print("\nЭТАП 2: Исследование времени выполнения запросов")
    print("-" * 50)
    try:
        query_investigator = QueryPerformanceInvestigator()
        query_investigator._setup_environment()
        query_investigator.run_query_investigation()
        query_investigator._cleanup_environment()
        print("Исследование запросов завершено успешно!")
    except Exception as e:
        print(f"Ошибка в исследовании запросов: {e}")

    # 3. Исследование эффективности индексов
    print("\nЭТАП 3: Исследование эффективности индексов (Пункт 6)")
    print("-" * 50)
    try:
        index_investigator = IndexEfficiencyInvestigator()
        index_investigator.run_index_investigation()
        print("Исследование индексов завершено успешно!")
    except Exception as e:
        print(f" Ошибка в исследовании индексов: {e}")


if __name__ == "__main__":
    main()
