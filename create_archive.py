import os
import zipfile

# Отримуємо поточну директорію, де виконується скрипт
current_directory = os.getcwd()

# Отримуємо ім'я директорії, де використовується скрипт
directory_name = os.path.basename(current_directory)

# Отримуємо версію з файлу RussianNameChecker.toc
toc_file = os.path.join(current_directory, "RussianNameChecker.toc")
version = "unknown"  # Значення за замовчуванням, якщо файл не знайдено
if os.path.isfile(toc_file):
    with open(toc_file, "r") as toc:
        for line in toc:
            if line.startswith("## Version:"):
                version = line.split(":")[1].strip()
                break

# Формуємо ім'я архіву
archive_name = f"{directory_name}_{version}.zip"

# Перевіряємо, чи існує вже архів з таким ім'ям, і видаляємо його, якщо так
if os.path.exists(archive_name):
    os.remove(archive_name)

# Шлях до папки, де всі файли та папки будуть вкладені
archive_directory = os.path.join(directory_name, "")

# Список розширень, які потрібно ігнорувати
ignored_extensions = ['.md', '.py', '.zip', '.yaml']

# Створюємо об'єкт архіву
with zipfile.ZipFile(archive_name, 'w', zipfile.ZIP_DEFLATED) as archive:
    # Рекурсивно додаємо всі файли та папки у поточній директорії в архів
    for root, dirs, files in os.walk(current_directory):
        # Видаляємо файли та папки, які починаються з крапки
        dirs[:] = [d for d in dirs if not d.startswith('.')]
        files = [f for f in files if not f.startswith('.')]

        for file in files:
            file_path = os.path.join(root, file)
            # Отримуємо розширення файлу і перевіряємо, чи потрібно ігнорувати цей файл
            file_extension = os.path.splitext(file_path)[1]
            if file_extension not in ignored_extensions:
                archive_path = os.path.join(archive_directory, os.path.relpath(file_path, current_directory))
                archive.write(file_path, archive_path)

print(f'Архів "{archive_name}" створено успішно в поточній директорії.')



