# Класс для создания и управления песочницей

import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT


class SandboxManager:

    def __init__(self, original_db_params):
        self.original_db_params = original_db_params
        self.sandbox_db_name = f"{original_db_params['database']}_sandbox"

    def create_sandbox(self):
        # Параметры для подключения к postgres
        postgres_params = self.original_db_params.copy()
        postgres_params['database'] = 'postgres'

        try:
            connection = psycopg2.connect(**postgres_params)
            connection.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
            cursor = connection.cursor()

            # удаляем песочницу если она существует
            cursor.execute(f"""
                SELECT pg_terminate_backend(pid)
                FROM pg_stat_activity
                WHERE datname = '{self.sandbox_db_name}'
            """)
            cursor.execute(f'DROP DATABASE IF EXISTS "{self.sandbox_db_name}"')

            print("Закрываем активные соединения с исходной БД")
            cursor.execute(f"""
                SELECT pg_terminate_backend(pid)
                FROM pg_stat_activity
                WHERE datname = '{self.original_db_params['database']}'
                AND pid <> pg_backend_pid()
            """)

            # создаём новую БД как копию оригинальной
            cursor.execute(f'''
                CREATE DATABASE "{self.sandbox_db_name}" 
                WITH TEMPLATE "{self.original_db_params['database']}"
            ''')

            cursor.close()
            connection.close()

            print(f"Песочница '{self.sandbox_db_name}' успешно создана!")
            return True

        except Exception as e:
            print(f"Ошибка при создании песочницы: {e}")
            # Если не удалось создать с помощью TEMPLATE, создаём пустую БД
            try:
                connection = psycopg2.connect(**postgres_params)
                connection.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
                cursor = connection.cursor()

                cursor.execute(f'CREATE DATABASE "{self.sandbox_db_name}"')
                cursor.close()
                connection.close()

                # Создаём таблицы в новой БД
                from .table_creator import TableCreator
                sandbox_params = self.get_sandbox_params()
                creator = TableCreator(sandbox_params)
                creator.create_all_tables()
                creator.insert_basic_services()

                print(f"Песочница '{self.sandbox_db_name}' создана как пустая БД с таблицами!")
                return True

            except Exception as e2:
                print(f"Не удалось создать песочницу: {e2}")
                return False

    def get_sandbox_params(self):
        sandbox_params = self.original_db_params.copy()
        sandbox_params['database'] = self.sandbox_db_name
        return sandbox_params

    def delete_sandbox(self):
        postgres_params = self.original_db_params.copy()
        postgres_params['database'] = 'postgres'

        try:
            connection = psycopg2.connect(**postgres_params)
            connection.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
            cursor = connection.cursor()

            # Закрываем все соединения с песочницей
            cursor.execute(f"""
                SELECT pg_terminate_backend(pid)
                FROM pg_stat_activity
                WHERE datname = '{self.sandbox_db_name}'
            """)

            # Удаляем песочницу
            cursor.execute(f'DROP DATABASE IF EXISTS "{self.sandbox_db_name}"')

            cursor.close()
            connection.close()

            print(f"Песочница '{self.sandbox_db_name}' удалена!")
            return True

        except Exception as e:
            print(f"Ошибка при удалении песочницы: {e}")
            return False

    def reset_sandbox(self):
        self.delete_sandbox()
        return self.create_sandbox()
