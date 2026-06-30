# Pawora

Инструкция по локальному запуску базы данных и управлению через pgAdmin 4.

## Запуск через Docker

В проекте настроен `docker-compose.yml`, который поднимает базу данных PostgreSQL и панель управления pgAdmin 4.

1. Перейдите в папку с бэкендом:
   ```bash
   cd backend
   ```
2. Создайте файл `.env` (если его нет) на основе примера.
3. Запустите контейнеры:
   ```bash
   docker-compose up -d
   ```

## Подключение в pgAdmin 4

После того как контейнеры запустятся, панель управления pgAdmin будет доступна в браузере.

1. Откройте в браузере: [http://localhost:5050](http://localhost:5050)
2. Используйте следующие данные для входа в панель pgAdmin:
   - **Email:** `admin@pawora.local`
   - **Password:** `admin`
3. После входа нужно добавить сервер для подключения к базе данных. Нажмите `Add New Server` и заполните:
   - **Вкладка General:**
     - **Name:** `Pawora DB` (или любое другое)
   - **Вкладка Connection:**
     - **Host name/address:** `postgres` (это имя контейнера в docker-compose)
     - **Port:** `5432` (используется внутренний порт контейнера 5432, не внешний 5433!)
     - **Maintenance database:** имя вашей базы (из `POSTGRES_DB` файла `.env`)
     - **Username:** ваш пользователь БД (из `POSTGRES_USER` файла `.env`)
     - **Password:** пароль БД (из `POSTGRES_PASSWORD` файла `.env`)
4. Нажмите `Save`. Теперь вы можете управлять базой данных из панели pgAdmin!

## Запуск без Docker (Локальная установка)

Если вы не хотите использовать Docker, вы можете установить PostgreSQL и pgAdmin 4 прямо на ваш компьютер:

1. Скачайте и установите **PostgreSQL** с [официального сайта](https://www.postgresql.org/download/). В процессе установки задайте пароль для пользователя `postgres` и запомните его. Убедитесь, что галочка для установки pgAdmin 4 также отмечена.
2. Откройте **pgAdmin 4** (через меню "Пуск" или список программ).
3. Подключитесь к локальному серверу PostgreSQL, введя пароль, который вы задали при установке.
4. В левом меню нажмите правой кнопкой мыши на `Databases` -> `Create` -> `Database...` и создайте базу данных `paworadb` (или с другим именем, соответствующим вашему `appsettings.json`).
5. В `backend/src/Pawora.API/appsettings.json` (или `.env`) укажите локальную строку подключения, например:
   `Host=localhost;Port=5432;Database=paworadb;Username=postgres;Password=ваш_пароль`

## DataSeed (Наполнение базы тестовыми данными)

Если вы запускаете проект с нуля и хотите быстро наполнить базу данных товарами и тестовым админом, выполните следующий SQL-скрипт через **Query Tool** в pgAdmin (Нажмите правой кнопкой на вашу базу -> `Query Tool`):

```sql
-- Создание тестового админа (пароль следует заменить на хеш, если используется Identity)
-- Вставьте актуальные данные или используйте регистрацию через приложение с последующей сменой роли в БД
INSERT INTO "Users" ("Id", "Name", "Email", "PasswordHash", "Role", "CreatedAt") 
VALUES (gen_random_uuid(), 'Admin', 'admin@pawora.local', 'HASH_PASSWORD_HERE', 'Admin', NOW());

-- Заполнение категорий (если есть таблица Categories)
INSERT INTO "Categories" ("Id", "Name", "Icon", "Color") VALUES
(gen_random_uuid(), 'Корма', 'food_icon', '#FF5733'),
(gen_random_uuid(), 'Игрушки', 'toy_icon', '#33FF57');

-- Заполнение товаров
INSERT INTO "Products" ("Id", "Title", "Description", "Price", "ImageUrl", "Stock", "CategoryId") 
VALUES 
(gen_random_uuid(), 'Корм для собак', 'Сухой корм супер-премиум класса для взрослых собак', 1500.00, 'https://example.com/dog_food.png', 50, (SELECT "Id" FROM "Categories" WHERE "Name" = 'Корма' LIMIT 1)),
(gen_random_uuid(), 'Мячик для кошек', 'Интерактивный мячик с колокольчиком', 300.00, 'https://example.com/cat_toy.png', 100, (SELECT "Id" FROM "Categories" WHERE "Name" = 'Игрушки' LIMIT 1));
```
*(Внимание: Названия таблиц и полей могут отличаться в зависимости от ваших EF Core миграций. Адаптируйте скрипт под вашу схему БД).*
