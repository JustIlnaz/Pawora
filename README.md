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

## Вопросы и ответы при защите

**1. Какой стек технологий использован в проекте?**
- Бэкенд: ASP.NET Core Web API, PostgreSQL, Entity Framework Core.
- Мобильное приложение: Flutter (Dart), Provider для управления состоянием.
- Инфраструктура: Docker (PostgreSQL, pgAdmin 4) + возможность локального запуска без Docker.

**2. Как происходит аутентификация пользователей?**
- JWT‑токены, которые выдаются после входа и обновляются через эндпоинт `/api/auth/refresh`.
- Токены хранятся в `SecureStorage` на клиенте.

**3. Как реализовано хранение избранных товаров?**
- В `FavoriteProvider` список хранится в `FlutterSecureStorage`.
- Для каждого пользователя используется отдельный ключ `favorite_products_<userId>`, чтобы избранное не было общим.

**4. Почему в мобильном клиенте был изменён порт с 5000 на 5041?**
- При запуске API через Visual Studio (`launchSettings.json`) приложение слушает `http://localhost:5041`.
- Было исправлено в `api_client.dart`, чтобы запросы шли на правильный порт.

**5. Как быстро наполнить базу тестовыми данными?**
- В README уже присутствует секция **DataSeed** с примером SQL‑скрипта, который можно выполнить в pgAdmin.

**6. Как запустить приложение без Docker?**
- Установить PostgreSQL и pgAdmin 4, создать базу `paworadb`, задать в `appsettings.json` строку подключения к `localhost:5432` и запустить `dotnet run`.
- После этого запустить Flutter‑приложение (`flutter run`).

**7. Какие основные функции реализованы в мобильном клиенте?**
- Просмотр каталога товаров, добавление/удаление товаров в корзину, оформление заказа, управление профилем, избранное, работа с картой.
- Используется Provider для управления состоянием (Auth, Product, Cart, Favorite, etc.).

**8. Какие улучшения планируются?**
- Добавить push‑уведомления о статусе заказа.
- Реализовать более гибкую роль‑базированную авторизацию.
- Перейти на Riverpod или Bloc для управления состоянием.
## Дополнительные вопросы по мобильному приложению

**9. Как реализовано состояние асинхронных запросов и отображается индикатор загрузки?**
- Каждый провайдер (например, `ProductProvider`) имеет булевый флаг `isLoading`. При начале запроса он ставится `true`, UI проверяет флаг и показывает `CircularProgressIndicator`. После получения данных `isLoading` становится `false` и UI обновляется через `notifyListeners()`.

**10. Как реализовано кеширование полученных данных?**
- После первого запроса список товаров сохраняется в поле `_products`. При последующих запросах провайдер проверяет, есть ли уже данные, и, если они присутствуют, использует их без повторного обращения к API (можно вызвать `refresh()` для принудительного обновления).

**11. Как реализована реактивность UI?**
- Все провайдеры наследуют `ChangeNotifier`. При изменении состояния вызывается `notifyListeners()`, а виджеты, обернутые в `Consumer`/`Provider.of`, автоматически перестраиваются.

**12. Как реализовано переключение тем (светлая/тёмная) в приложении?**
- В `theme/app_theme.dart` определены `darkTheme` и `lightTheme`. `ThemeProvider` хранит текущий `ThemeMode` в `SharedPreferences` и предоставляет метод `toggleTheme()`. `MaterialApp` получает `themeMode` из этого провайдера.

**13. Как реализована пагинация списка товаров?**
- `ProductProvider` использует параметры `page` и `pageSize`. При прокрутке до конца списка вызывается `loadMore()`, который запрашивает следующую страницу и добавляет новые элементы к уже загруженным.

**14. Как реализовано отображение детальной информации о товаре?**
- На экране `ProductDetailScreen` используется `FutureBuilder`, который получает полные данные о товаре (включая отзывы) через метод `ApiClient.getProductDetail(id)`.

**15. Как реализовано добавление отзывов к товару?**
- `ReviewProvider` отправляет `POST /reviews` с полями `productId`, `rating`, `comment`. После успешного добавления вызывается `loadReviews(productId)`, чтобы обновить список отзывов.

**16. Как реализовано хранение токенов в безопасном хранилище?**
- Токены сохраняются в `FlutterSecureStorage` под ключами `access_token` и `refresh_token`. При старте `AuthProvider` читает их и проверяет срок действия.

**17. Как реализовано автоматическое обновление access‑token при получении 401?**
- В `ApiClient` установлен `interceptor`. При получении ответа 401 вызывается метод `refreshToken()`, который отправляет запрос к `/auth/refresh`. Если обновление успешно, оригинальный запрос повторяется автоматически.

**18. Как реализовано отображение карты с маркерами магазинов?**
- `MapScreen` использует пакет `google_maps_flutter`. Маркеры получаются из API `/shops`. При нажатии на маркер открывается диалог с информацией о магазине и кнопкой «Перейти к товарам».

**19. Как реализовано получение текущей позиции пользователя?**
- Пакет `location` запрашивает разрешения и получает координаты, которые передаются в `MapScreen` для центрирования карты.

**20. Как реализовано действие выхода (logout) пользователя?**
- В `AuthProvider.logout()` удаляются токены из `SecureStorage`, сбрасывается состояние `user = null` и вызывается `Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false)`.

**21. Как реализовано удаление аккаунта пользователя?**
- `UserProvider.deleteAccount()` отправляет `DELETE /users/{id}`. При успешном ответе вызывается `authProvider.logout()`.

**22. Как реализовано отображение ошибок в UI?**
- Ошибки из `DioError` преобразуются в пользовательские сообщения и показываются через `ScaffoldMessenger.of(context).showSnackBar`.

**23. Как реализована адаптивность интерфейса под разные размеры экранов?**
- Используются `LayoutBuilder`, `MediaQuery`, а также `Flexible`/`Expanded` в `Row`/`Column`. Тестировано на мобильных и планшетных эмуляторах.

**24. Как реализовано юнит‑тестирование бизнес‑логики провайдеров?**
- В каталоге `test/` находятся тесты, использующие `mockito` для подмены `ApiClient`. Тестируются методы `addItem`, `removeItem`, `toggleFavorite`, а также обработка ответов API.

**25. Как реализована локализация текста приложения?**
- Файлы локализации находятся в `assets/l10n/*.arb`. В коде используется `AppLocalizations.of(context)!.someKey`. Добавление нового языка требует создания нового `.arb`‑файла и генерации кода `flutter gen-l10n`.

**26. Как реализовано кеширование изображений товаров?**
- Пакет `cached_network_image` сохраняет загруженные изображения в локальный кэш устройства, что ускоряет последующие загрузки и обеспечивает работу офлайн.

**27. Как реализовано отображение списка избранных товаров?**
- `FavoritesScreen` получает список избранных ID из `FavoriteProvider.isFavorite` и фильтрует `productProvider.products`. При добавлении/удалении из избранного вызывается `notifyListeners()`, и UI обновляется автоматически.

**28. Как реализовано обновление списка избранного при смене пользователя?**
- При логине `AuthProvider` вызывает `favoriteProvider.updateUser(auth.user?.id)`, что сбрасывает текущий список и загружает избранное из `FlutterSecureStorage` по новому ключу `favorite_products_<userId>`.

**29. Как реализовано отображение статуса загрузки в списках (например, товары, отзывы)?**
- Каждый список имеет отдельный флаг `isLoading`. Пока данные загружаются, отображается `CircularProgressIndicator` в центре экрана или внизу списка при пагинации.

**30. Как реализовано переключение языка интерфейса?**
- `LocaleProvider` хранит текущую локаль в `SharedPreferences`. При смене языка вызывается `setLocale(Locale('ru'))` или `setLocale(Locale('en'))`, после чего `MaterialApp` получает `locale` из провайдера.

---

## Валидация в мобильном приложении

### Формы и ввод данных
* Для всех форм используется `Form` + `TextFormField` с параметром `validator`. Пример:
```dart
TextFormField(
  controller: _emailController,
  decoration: const InputDecoration(labelText: 'Email'),
  validator: (value) {
    if (value == null || value.isEmpty) return 'Введите email';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$');
    if (!emailRegex.hasMatch(value)) return 'Некорректный email';
    return null;
  },
),
```
* При отправке формы проверяется `if (_formKey.currentState!.validate()) { … }`.
* Для пароля проверяется минимум 6 символов и наличие цифр/букв.

### Валидация карты и геолокации
* При запросе текущей локации используется пакет `location`. Перед запросом проверяется наличие разрешений `LocationPermission.whenInUse`/`always`. Если разрешения отсутствуют – показывается диалог с просьбой включить их.
* Координаты проверяются на диапазоны: `latitude` от -90 до 90, `longitude` от -180 до 180. При выходе за пределы выводится `SnackBar` с ошибкой.
* При добавлении маркера пользователь может перемещать его; позиция сохраняется только после подтверждения кнопкой `Save`. Если пользователь пытается установить маркер за пределами области магазина – отображается `AlertDialog`.
* Ошибки сети (например, не удалось загрузить список магазинов) обрабатываются в `ApiClient` и отображаются через `ScaffoldMessenger`.

### Общие правила валидации
* Все пользовательские вводы (email, пароль, адрес, телефон) проверяются как на клиенте, так и на сервере.
* При работе с формами используется `autovalidateMode: AutovalidateMode.onUserInteraction` для мгновенной обратной связи.
* Для полей, требующих числовой ввод (например, количество товаров), используется `keyboardType: TextInputType.number` и проверка `int.tryParse(value)`.
* При неправильных данных UI показывает сообщение в `SnackBar` и не отправляет запрос к API.

---

## Структура папки `lib/` — описание всех файлов

### `main.dart`
Точка входа приложения. Инициализирует все `Provider`'ы (`MultiProvider`), задаёт тему, локаль и корневой маршрут. Здесь подключаются `AuthProvider`, `ProductProvider`, `CartProvider`, `FavoriteProvider` и остальные.

---

### Папка `models/` — модели данных

| Файл | Описание |
|---|---|
| `auth_response.dart` | Модель ответа сервера при логине/регистрации. Содержит `accessToken`, `refreshToken` и объект `User`. |
| `cart_item.dart` | Элемент корзины: `productId`, `quantity`. Используется в `CartProvider`. |
| `category.dart` | Категория товара: `id`, `name`, `icon`, `color`. Используется для фильтрации каталога. |
| `order.dart` | Заказ: `id`, `status`, `totalPrice`, `createdAt`, список `OrderItem`. |
| `order_item.dart` | Элемент заказа: `productId`, `title`, `price`, `quantity`, `imageUrl`. |
| `payment_card.dart` | Банковская карта: `id`, `cardNumber`, `holderName`, `expiryDate`, `isDefault`. |
| `pet.dart` | Питомец пользователя: `id`, `name`, `type`, `breed`, `age`, `imageUrl`. |
| `product.dart` | Товар: `id`, `title`, `description`, `price`, `imageUrl`, `stock`, `categoryId`, `rating`. |
| `review.dart` | Отзыв: `id`, `userId`, `userName`, `productId`, `rating`, `comment`, `createdAt`. |
| `shop.dart` | Магазин: `id`, `name`, `address`, `latitude`, `longitude`, `phone`, `workingHours`. |
| `user.dart` | Пользователь: `id`, `name`, `email`, `role`, `avatarUrl`. |
| `user_address.dart` | Адрес пользователя: `id`, `title`, `address`, `city`, `isDefault`. |

---

### Папка `providers/` — управление состоянием (ChangeNotifier)

| Файл | Описание |
|---|---|
| `address_provider.dart` | CRUD адресов пользователя. Методы: `loadAddresses()`, `addAddress()`, `deleteAddress()`, `setDefault()`. |
| `admin_provider.dart` | Администрирование: получение статистики, управление товарами и заказами из админ‑панели. |
| `auth_provider.dart` | Аутентификация: `login()`, `register()`, `logout()`, хранение токенов в `SecureStorage`, автоматический `refreshToken`. |
| `cart_provider.dart` | Корзина: `addItem()`, `removeItem()`, `updateQuantity()`, `clearCart()`. Считает `totalPrice`. |
| `favorite_provider.dart` | Избранное: `toggleFavorite()`, `isFavorite()`, `loadFavorites()`. Хранит данные по ключу `favorite_products_<userId>`. |
| `order_provider.dart` | Заказы: `createOrder()`, `loadOrders()`, `cancelOrder()`. Показывает историю. |
| `payment_provider.dart` | Платёжные карты: `loadCards()`, `addCard()`, `deleteCard()`, `setDefaultCard()`. |
| `pet_provider.dart` | Питомцы: `loadPets()`, `addPet()`, `updatePet()`, `deletePet()`. |
| `product_provider.dart` | Каталог товаров: `loadProducts()`, `loadMore()` (пагинация), `searchProducts()`, фильтрация по категории. |
| `shop_provider.dart` | Магазины: `loadShops()` — загружает список магазинов для карты. |
| `user_provider.dart` | Профиль: `loadProfile()`, `updateProfile()`, `deleteAccount()`. |

---

### Папка `screens/` — экраны (страницы)

| Файл | Описание |
|---|---|
| `splash_screen.dart` | Стартовый экран с логотипом. Проверяет наличие токена и перенаправляет на `HomeScreen` или `WelcomeScreen`. |
| `welcome_screen.dart` | Приветственный экран с кнопками «Войти» и «Регистрация». |
| `login_screen.dart` | Форма входа: email + пароль, валидация, вызов `authProvider.login()`. |
| `register_screen.dart` | Форма регистрации: имя, email, пароль, подтверждение пароля. |
| `main_screen.dart` | Корневой навигатор с `BottomNavigationBar`, переключает `HomeScreen`, `CartScreen`, `ProfileScreen`. |
| `home_screen.dart` | Главная: категории (горизонтальный список), товары (сетка), строка поиска. |
| `search_screen.dart` | Поиск товаров по названию с фильтрацией в реальном времени. |
| `product_detail_screen.dart` | Детали товара: изображения, описание, цена, кнопка «В корзину», список отзывов, возможность добавить отзыв. |
| `cart_screen.dart` | Корзина: список товаров, изменение количества, удаление, итоговая сумма, кнопка «Оформить». |
| `checkout_screen.dart` | Оформление заказа: выбор адреса, способа оплаты, подтверждение. |
| `favorites_screen.dart` | Список избранных товаров, возможность удаления из избранного. |
| `profile_screen.dart` | Профиль пользователя: аватар, имя, email, кнопки настроек, питомцев, адресов, заказов. |
| `edit_profile_screen.dart` | Редактирование профиля: изменение имени, email, аватара. |
| `settings_screen.dart` | Настройки: переключение темы (светлая/тёмная), смена языка. |
| `order_history_screen.dart` | История заказов пользователя со статусами. |
| `payment_methods_screen.dart` | Управление банковскими картами: список, добавление, удаление, выбор карты по умолчанию. |
| `add_card_screen.dart` | Форма добавления карты: номер, имя владельца, срок, CVV. Валидация по алгоритму Луна. |
| `add_pet_screen.dart` | Форма добавления питомца: имя, тип, порода, возраст, фото. |
| `add_product_screen.dart` | Создание/редактирование товара (админ): название, описание, цена, категория, изображение. |
| `address_management_screen.dart` | Управление адресами: список, добавление нового, установка по умолчанию, удаление. |
| `admin_dashboard_screen.dart` | Панель администратора: статистика (кол‑во товаров, заказов, пользователей), навигация к управлению. |
| `admin_orders_screen.dart` | Список всех заказов (админ): просмотр, смена статуса. |
| `admin_products_screen.dart` | Управление товарами (админ): список, редактирование, удаление. |
| `map_screen.dart` | Карта магазинов на `GoogleMap` с маркерами. При нажатии — информация о магазине. |
| `help_screen.dart` | Экран помощи / FAQ для пользователя. |

---

### Папка `services/` — сервисный слой (работа с API и хранилищем)

| Файл | Описание |
|---|---|
| `api_client.dart` | Обёртка над `Dio`. Настраивает `baseUrl`, заголовки (`Authorization: Bearer`), интерцептор для автообновления токена при 401. |
| `auth_service.dart` | Методы: `login(email, password)`, `register(name, email, password)`, `refreshToken(token)`. Возвращает `AuthResponse`. |
| `product_service.dart` | Методы: `getProducts(page, pageSize, categoryId)`, `getProductDetail(id)`, `createProduct()`, `updateProduct()`, `deleteProduct()`. |
| `order_service.dart` | Методы: `getOrders()`, `createOrder(items, addressId, cardId)`, `cancelOrder(id)`, `updateOrderStatus(id, status)`. |
| `shop_service.dart` | Метод: `getShops()` — возвращает список магазинов с координатами. |
| `pet_service.dart` | Методы: `getPets()`, `addPet()`, `updatePet()`, `deletePet()`. |
| `review_service.dart` | Методы: `getReviews(productId)`, `addReview(productId, rating, comment)`. |
| `address_service.dart` | Методы: `getAddresses()`, `addAddress()`, `deleteAddress()`, `setDefaultAddress()`. |
| `upload_service.dart` | Загрузка изображений на сервер (`multipart/form-data`). Возвращает URL загруженного файла. |
| `user_service.dart` | Методы: `getProfile()`, `updateProfile()`, `deleteAccount()`. |
| `storage_service.dart` | Обёртка над `FlutterSecureStorage`. Хранение токенов (`access_token`, `refresh_token`) и избранного (`favorite_products_<userId>`). |

---

### Папка `theme/` — темы оформления

| Файл | Описание |
|---|---|
| `app_theme.dart` | Определяет `lightTheme` и `darkTheme` (`ThemeData`). Настроены цвета, типографика, стили кнопок, карточек, `AppBar`, `BottomNavigationBar`. |

---

### Папка `utils/` — утилиты

| Файл | Описание |
|---|---|
| `error_handler.dart` | Обработчик ошибок: преобразует `DioException` в пользовательские сообщения на русском, показывает `SnackBar`. Обрабатывает 400, 401, 403, 404, 500 и ошибки сети. |

---

### Папка `widgets/` — переиспользуемые виджеты

| Файл | Описание |
|---|---|
| `app_bar_widget.dart` | Кастомный `AppBar` с единым стилем для всех экранов. |
| `bottom_nav_bar.dart` | Нижняя панель навигации с иконками: Главная, Поиск, Корзина, Профиль. Показывает бейдж с количеством товаров в корзине. |
| `category_chip.dart` | Виджет‑чип для отображения категории. Поддерживает выделение активной категории. |
| `custom_button.dart` | Стилизованная кнопка с загрузочным состоянием (`isLoading`). |
| `custom_text_field.dart` | Стилизованное текстовое поле с иконкой и валидацией. |
| `empty_state.dart` | Заглушка «Нет данных» с иконкой и текстом (используется при пустых списках). |
| `error_state.dart` | Виджет ошибки с кнопкой «Повторить». |
| `loading_state.dart` | Индикатор загрузки (`CircularProgressIndicator` или `Shimmer`). |
| `order_card.dart` | Карточка заказа: номер, статус (с цветовым индикатором), дата, сумма, список товаров. |
| `pet_card.dart` | Карточка питомца: фото, имя, порода, возраст. |
| `product_card.dart` | Карточка товара в сетке: изображение, название, цена, кнопка «В избранное» (сердечко). |
| `review_card.dart` | Карточка отзыва: имя автора, рейтинг (звёзды), текст, дата. |
| `shop_card.dart` | Карточка магазина: название, адрес, телефон, время работы, кнопка «На карте». |

---

## Вопросы и ответы по каждому файлу из `lib/`

**В1. Что делает `main.dart` и почему в нём `MultiProvider`?**
`main.dart` — точка входа. `MultiProvider` позволяет зарегистрировать все `ChangeNotifier`‑провайдеры в одном месте, чтобы любой виджет в дереве мог получить к ним доступ через `Provider.of` или `Consumer`. `FavoriteProvider` обёрнут в `ChangeNotifierProxyProvider`, чтобы автоматически получать `userId` из `AuthProvider`.

**В2. Почему модели (`models/`) выделены в отдельную папку?**
Модели представляют структуру данных, приходящих с сервера (JSON). Каждая модель имеет `fromJson()` и `toJson()` для сериализации. Вынос в отдельную папку обеспечивает чистую архитектуру и переиспользуемость.

**В3. Как устроена модель `product.dart`?**
Содержит поля: `id`, `title`, `description`, `price`, `imageUrl`, `stock`, `categoryId`, `rating`. Фабричный конструктор `Product.fromJson(Map<String, dynamic>)` маппит JSON в объект. Метод `toJson()` используется при создании/обновлении товара.

**В4. Зачем нужна модель `auth_response.dart`?**
Сервер при логине возвращает `accessToken`, `refreshToken` и данные `User` одним объектом. Модель `AuthResponse` десериализует этот ответ и передаётся в `AuthProvider` для сохранения токенов.

**В5. Как `auth_provider.dart` хранит сессию пользователя?**
Токены сохраняются в `FlutterSecureStorage` (шифрованное хранилище). При старте приложения `AuthProvider` читает токен и проверяет его наличие. Если токен есть — пользователь считается авторизованным. При 401 ошибке вызывается `refreshToken()`.

**В6. Как работает `cart_provider.dart`?**
Хранит `List<CartItem>`. Методы: `addItem(productId)` — добавляет или увеличивает `quantity`; `removeItem(productId)` — удаляет; `updateQuantity(productId, qty)` — обновляет количество. Геттер `totalPrice` считает сумму. После каждого изменения — `notifyListeners()`.

**В7. Как `favorite_provider.dart` разделяет избранное между пользователями?**
Ключ хранения: `favorite_products_<userId>`. При смене пользователя вызывается `updateUser(newUserId)`, который сбрасывает список и загружает избранное из `SecureStorage` по новому ключу.

**В8. Что делает `product_provider.dart` при пагинации?**
Хранит `page`, `pageSize`, `hasMore`. Метод `loadMore()` увеличивает `page`, запрашивает следующую порцию через `ProductService.getProducts(page, pageSize)` и добавляет результаты к `_products`. Если пришло меньше `pageSize` элементов — `hasMore = false`.

**В9. Как `payment_provider.dart` работает с картами?**
Загружает список карт через `API`, позволяет добавить новую карту, удалить и установить карту по умолчанию. При оформлении заказа `CheckoutScreen` получает выбранную карту из этого провайдера.

**В10. Как устроен `api_client.dart`?**
Создаёт экземпляр `Dio` с `baseUrl` из конфигурации. Добавляет интерцептор: при запросе подставляет `Authorization: Bearer <token>`; при ответе 401 вызывает `/auth/refresh`, обновляет токен и повторяет оригинальный запрос. При ошибке сети выбрасывает понятное исключение.

**В11. Зачем нужен `storage_service.dart`?**
Единая точка доступа к `FlutterSecureStorage`. Методы: `saveToken()`, `getToken()`, `deleteToken()`, `saveFavorites(userId, ids)`, `getFavorites(userId)`. Инкапсулирует работу с ключами, чтобы провайдеры не знали о деталях хранения.

**В12. Что делает `upload_service.dart`?**
Отправляет файл (изображение) на сервер через `multipart/form-data`. Используется при добавлении товара, питомца или смене аватара. Возвращает URL загруженного изображения.

**В13. Как устроена тёмная тема в `app_theme.dart`?**
Определены два `ThemeData`: `lightTheme` и `darkTheme`. Настроены `colorScheme`, `textTheme`, стили `ElevatedButton`, `Card`, `AppBar`, `InputDecoration`. Переключение происходит через `ThemeMode` в `MaterialApp`.

**В14. Как `error_handler.dart` обрабатывает ошибки?**
Принимает `DioException`, анализирует `statusCode` (400 — ошибка валидации, 401 — не авторизован, 403 — нет прав, 404 — не найдено, 500 — ошибка сервера). Для сетевых ошибок (timeout, no connection) выводит «Проверьте подключение к интернету». Результат показывается через `SnackBar`.

**В15. Как работает `product_card.dart`?**
Принимает объект `Product`. Отображает изображение через `CachedNetworkImage`, название, цену. В правом верхнем углу — иконка сердечка (избранное), при нажатии вызывается `favoriteProvider.toggleFavorite(product.id)`. При нажатии на карточку — навигация к `ProductDetailScreen`.

**В16. Как работает `bottom_nav_bar.dart`?**
Отображает 4 вкладки: Главная, Поиск, Корзина, Профиль. На иконке корзины показывается бейдж `Badge` с количеством товаров из `CartProvider`. При переключении вкладки вызывается `onTap(index)` в `MainScreen`.

**В17. Как реализована валидация карты в `add_card_screen.dart`?**
Номер карты проверяется алгоритмом Луна (Luhn). Срок действия — формат `MM/YY`, проверяется, что месяц от 01 до 12 и карта не просрочена. CVV — ровно 3 цифры. Имя владельца — не пустое, только латиница. Все проверки выполняются через `validator` в `TextFormField`.

**В18. Как `checkout_screen.dart` собирает данные для заказа?**
Получает список товаров из `CartProvider`, адрес из `AddressProvider` (выбранный по умолчанию или выбранный пользователем), карту из `PaymentProvider`. При нажатии «Подтвердить» вызывает `orderProvider.createOrder(items, addressId, cardId)`. При успехе — очищает корзину и переходит к истории заказов.

**В19. Что делает `splash_screen.dart`?**
Показывает логотип приложения и анимацию. В `initState` проверяет наличие токена через `AuthProvider`. Если токен валиден — переход на `MainScreen`, если нет — на `WelcomeScreen`. Задержка 2 секунды для визуального эффекта.

**В20. Как работает `order_card.dart`?**
Принимает `Order`. Отображает номер заказа, дату, статус (цветная метка: зелёный — доставлен, жёлтый — в обработке, красный — отменён), общую сумму и превью товаров (первые 2–3 изображения).

**В21. Как устроен `admin_dashboard_screen.dart`?**
Показывает статистику: количество товаров, активных заказов, пользователей. Карточки с навигацией к `AdminProductsScreen` и `AdminOrdersScreen`. Данные загружаются через `AdminProvider`.

**В22. Как `search_screen.dart` выполняет поиск?**
Использует `TextField` с `onChanged`. При вводе текста вызывается `productProvider.searchProducts(query)` с дебаунсом (задержка 300 мс). Результаты отображаются в `ListView` в реальном времени.

**В23. Зачем нужен `empty_state.dart`?**
Показывается, когда список пуст (нет товаров, нет заказов, нет избранного). Содержит иконку и текст («Здесь пока ничего нет»). Используется во всех экранах со списками для единообразного UX.

**В24. Как `shop_card.dart` связан с `map_screen.dart`?**
`ShopCard` отображает информацию о магазине и имеет кнопку «На карте». При нажатии вызывается навигация к `MapScreen` с передачей координат конкретного магазина для центрирования карты.

**В25. Как `address_management_screen.dart` управляет адресами?**
Отображает список адресов из `AddressProvider`. Позволяет добавить новый адрес (форма с валидацией), удалить свайпом, установить по умолчанию. Адрес по умолчанию автоматически выбирается в `CheckoutScreen`.

**В26. Как реализована локализация и смена языка?**
Локализация реализована через собственный класс `AppLocalizations` и `LocaleProvider`. В `AppLocalizations` содержится статическая карта переводов для русского (`ru`) и английского (`en`) языков. `LocaleProvider` сохраняет выбранную локаль в `SharedPreferences` для сохранения состояния между перезапусками приложения. В `main.dart` зарегистрирован `LocaleProvider`, а `MaterialApp` настроен на использование `locale` из провайдера и `AppLocalizations.delegate` в качестве делегата локализации.

---

