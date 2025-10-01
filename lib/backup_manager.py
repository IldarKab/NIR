# Класс для создания бэкапов и восстановления данных БД
import os
import subprocess
import json
from datetime import datetime
from .db_context import DatabaseContext

# Класс для управления бэкапами БД
class BackupManager:
    def __init__(self, db_params, backup_dir="backups"):
        self.db_params = db_params
        self.backup_dir = backup_dir

        # создаём папку для бэкапов если её нет
        if not os.path.exists(backup_dir):
            os.makedirs(backup_dir)

    # создаем бэкап базы данных
    def create_backup(self, backup_name=None):

        if backup_name is None:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            backup_name = f"backup_{self.db_params['database']}_{timestamp}"

        backup_path = os.path.join(self.backup_dir, f"{backup_name}.sql")

        try:
            cmd = [
                'pg_dump',
                f"--host={self.db_params['host']}",
                f"--port={self.db_params['port']}",
                f"--username={self.db_params['user']}",
                f"--dbname={self.db_params['database']}",
                '--verbose',
                '--clean',
                '--no-owner',
                '--no-privileges',
                f"--file={backup_path}"
            ]

            # устанавливаем пароль через переменную окружения
            env = os.environ.copy()
            env['PGPASSWORD'] = self.db_params['password']

            result = subprocess.run(cmd, env=env, capture_output=True, text=True)

            if result.returncode == 0:
                print(f"Бэкап успешно создан: {backup_path}")
                self._save_backup_metadata(backup_name, backup_path)

                return backup_path
            else:
                print(f"Ошибка создания бэкапа: {result.stderr}")
                return None

        except Exception as e:
            print(f"Ошибка при создании бэкапа: {e}")
            return None

    # восстанавливает БД из бэкапа
    def restore_backup(self, backup_path):
        if not os.path.exists(backup_path):
            print(f"Файл бэкапа не найден: {backup_path}")
            return False

        try:
            # формируем команду psql для восстановления
            cmd = [
                'psql',
                f"--host={self.db_params['host']}",
                f"--port={self.db_params['port']}",
                f"--username={self.db_params['user']}",
                f"--dbname={self.db_params['database']}",
                '--quiet',
                f"--file={backup_path}"
            ]


            env = os.environ.copy()
            env['PGPASSWORD'] = self.db_params['password']

            result = subprocess.run(cmd, env=env, capture_output=True, text=True)

            if result.returncode == 0:
                print(f"Бэкап успешно восстановлен из: {backup_path}")
                return True
            else:
                print(f"Ошибка восстановления бэкапа: {result.stderr}")
                return False

        except Exception as e:
            print(f"Ошибка при восстановлении бэкапа: {e}")
            return False

    # Создаёт бэкап только данных (без схемы)
    def create_data_backup(self, backup_name=None):

        if backup_name is None:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            backup_name = f"data_backup_{self.db_params['database']}_{timestamp}"

        backup_data = {}

        # список таблиц для бэкапа данных
        tables = ['clients', 'suppliers', 'cars', 'orders', 'services',
                 'client_documents', 'order_services']

        with DatabaseContext(**self.db_params) as cursor:
            for table in tables:
                cursor.execute(f"SELECT * FROM {table}")
                columns = [desc[0] for desc in cursor.description]
                rows = cursor.fetchall()

                # Преобразуем данные в JSON-совместимый формат
                table_data = []
                for row in rows:
                    row_dict = {}
                    for i, value in enumerate(row):
                        # Обрабатываем специальные типы данных
                        if hasattr(value, 'isoformat'):  # datetime/date
                            row_dict[columns[i]] = value.isoformat()
                        elif hasattr(value, '__str__'):  # Decimal и другие
                            row_dict[columns[i]] = str(value)
                        else:
                            row_dict[columns[i]] = value
                    table_data.append(row_dict)

                backup_data[table] = {
                    'columns': columns,
                    'data': table_data
                }

        # cохраняем в JSON файл
        backup_path = os.path.join(self.backup_dir, f"{backup_name}.json")
        with open(backup_path, 'w', encoding='utf-8') as f:
            json.dump(backup_data, f, ensure_ascii=False, indent=2)

        print(f"Бэкап данных создан: {backup_path}")
        return backup_path
    # Возвращает список доступных бэкапов
    def list_backups(self):
        backups = []
        if os.path.exists(self.backup_dir):
            for filename in os.listdir(self.backup_dir):
                if filename.endswith(('.sql', '.json')):
                    filepath = os.path.join(self.backup_dir, filename)
                    stat = os.stat(filepath)
                    backups.append({
                        'name': filename,
                        'path': filepath,
                        'size': stat.st_size,
                        'created': datetime.fromtimestamp(stat.st_ctime)
                    })

        return sorted(backups, key=lambda x: x['created'], reverse=True)
    # cохраняет метаданные бэкапа
    def _save_backup_metadata(self, backup_name, backup_path):
        metadata = {
            'name': backup_name,
            'path': backup_path,
            'database': self.db_params['database'],
            'created': datetime.now().isoformat(),
            'host': self.db_params['host']
        }

        metadata_path = os.path.join(self.backup_dir, f"{backup_name}_metadata.json")
        with open(metadata_path, 'w', encoding='utf-8') as f:
            json.dump(metadata, f, ensure_ascii=False, indent=2)
