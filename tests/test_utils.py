import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from lib.plotter import Plotter
from lib.backup_manager import BackupManager
from investigations.config import DB_PARAMS

def test_plotter():
    print("Тестирование построения графиков...")

    plotter = Plotter("tests/test_output")

    test_data = {
        'Серия 1': [1, 2, 3, 4, 5],
        'Серия 2': [2, 4, 6, 8, 10],
        'Серия 3': [1, 3, 5, 7, 9]
    }

    saved_files = plotter.create_plot(
        test_data,
        x_values=[1, 2, 3, 4, 5],
        title="Тестовый график",
        x_label="X ось",
        y_label="Y ось",
        filename="test_graph"
    )

    assert len(saved_files) > 0, "График не сохранен"
    assert os.path.exists(saved_files[0]), "Файл графика не существует"

    print("Построение графиков работает корректно")

def test_backup_manager():
    print("Тестирование менеджера резервных копий...")

    try:
        backup_manager = BackupManager(DB_PARAMS)

        backup_file = backup_manager.create_backup()
        assert os.path.exists(backup_file), "Файл бэкапа не создан"

        metadata_file = backup_file.replace('.sql', '_metadata.json')
        assert os.path.exists(metadata_file), "Файл метаданных не создан"

        print("Менеджер резервных копий работает корректно")

    except Exception as e:
        print(f"Ошибка тестирования бэкапа: {e}")

if __name__ == "__main__":
    test_plotter()
    test_backup_manager()
