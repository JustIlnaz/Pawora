# Схема базы данных проекта «Pawora»

На этой странице представлена интерактивная диаграмма сущностей (Entity Relationship Diagram) базы данных PostgreSQL проекта «Pawora».

```mermaid
erDiagram
    USER {
        guid Id PK
        string Email "Unique"
        string PasswordHash
        string FullName
        string Phone
        string AvatarUrl
        string Role "Enum"
        datetime CreatedAt
    }
    
    SHOP {
        guid Id PK
        string Name
        string Description
        string Address
        double Latitude
        double Longitude
        string ImageUrl
        guid OwnerId FK
        string Phone
        double Rating
        datetime CreatedAt
    }
    
    CATEGORY {
        guid Id PK
        string Name
        string IconName
        int SortOrder
        datetime CreatedAt
    }
    
    PRODUCT {
        guid Id PK
        string Name
        string Description
        decimal Price
        decimal DiscountPrice
        string ImageUrl
        guid ShopId FK
        guid CategoryId FK
        int Stock
        double Rating
        int ReviewCount
        datetime CreatedAt
    }
    
    ORDER {
        guid Id PK
        guid UserId FK
        guid ShopId
        string Status "Enum"
        decimal TotalAmount
        string Address
        datetime CreatedAt
    }
    
    ORDER_ITEM {
        guid Id PK
        guid OrderId FK
        guid ProductId FK
        int Quantity
        decimal UnitPrice
        datetime CreatedAt
    }
    
    REVIEW {
        guid Id PK
        guid UserId FK
        guid ProductId FK
        int Rating
        string Comment
        string AdminReply
        datetime AdminReplyCreatedAt
        datetime CreatedAt
    }
    
    PET {
        guid Id PK
        guid UserId FK
        string Name
        string Species
        string Breed
        datetime BirthDate
        string ImageUrl
        datetime CreatedAt
    }
    
    REFRESH_TOKEN {
        guid Id PK
        guid UserId FK
        string Token
        datetime ExpiresAt
        bool IsRevoked
        datetime CreatedAt
    }
    
    USER_ADDRESS {
        guid Id PK
        guid UserId FK
        string AddressText
        bool IsDefault
        datetime CreatedAt
    }

    USER ||--o{ ORDER : "делает заказы"
    USER ||--o{ REVIEW : "пишет отзывы"
    USER ||--o{ PET : "добавляет питомцев"
    USER ||--o{ REFRESH_TOKEN : "получает токены"
    USER ||--o{ USER_ADDRESS : "сохраняет адреса"
    USER ||--o{ SHOP : "управляет магазинами"
    SHOP ||--o{ PRODUCT : "предлагает товары"
    CATEGORY ||--o{ PRODUCT : "группирует товары"
    PRODUCT ||--o{ REVIEW : "получает отзывы"
    PRODUCT ||--o{ ORDER_ITEM : "входит в заказы"
    ORDER ||--|{ ORDER_ITEM : "содержит позиции"
```

### Описание связей
* **Пользователи (`USER`):** Является центральной сущностью. Связан «один-ко-многим» с заказами, отзывами, питомцами, адресами доставки и рефреш-токенами. Также пользователь с ролью `Admin` может владеть магазинами.
* **Магазины (`SHOP`):** Владельцем магазина является пользователь (связь с `USER`). В магазине продаются товары (связь «один-ко-многим» с `PRODUCT`).
* **Товары (`PRODUCT`):** Обязательно принадлежат магазину (`ShopId`) и категории (`CategoryId`). Товар может содержать отзывы пользователей (`REVIEW`) и входить в различные пункты заказов (`ORDER_ITEM`).
* **Заказы (`ORDER`):** Содержат одну или несколько позиций (`ORDER_ITEM`), которые жестко привязаны к конкретному товару (`ProductId`).
