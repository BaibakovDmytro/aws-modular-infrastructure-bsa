import boto3
from datetime import datetime

# 1. Инициализация (Подключаемся к нашему "станку")
dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
table = dynamodb.Table('ProcessedFilesTable')

def mark_file_as_processed(file_name):
    # 2. Логика управления: фиксируем результат в базе
    try:
        table.put_item(
            Item={
                'FileName': file_name,
                'Status': 'COMPLETED',
                'Timestamp': datetime.now().isoformat(),
                'FileSize': '15MB',           # Запятая в конце обязательна
                'Region': 'Canada-East',      # Запятая в конце обязательна
                'Owner': 'Dmitry'             # Тут запятая не обязательна, но можно
            }
        ) # Только ОДНА закрывающая скобка для функции put_item

        print(f"--- РЕЗУЛЬТАТ: Файл {file_name} успешно зафиксирован в DynamoDB ---")
    except Exception as e:
        print(f"--- ОШИБКА: Не удалось записать в базу. Проверь права IAM! --- \n{e}")

# 3. Тестовый запуск
if __name__ == "__main__":
    test_file = "canada_report_march_04.csv"
    mark_file_as_processed(test_file)