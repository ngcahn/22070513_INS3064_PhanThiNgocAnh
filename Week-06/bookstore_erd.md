# Online Bookstore Database — ERD

**Student:** Phan Thi Ngoc Anh  
**Course:** INS3064 — Homework 6: Database Design

## 1. Entities and attributes

Notation: **PK** = Primary Key, **FK** = Foreign Key, **UQ** = Unique.

### authors
- `author_id` INT **PK**
- `author_name` VARCHAR(150) NOT NULL
- `biography` TEXT
- `nationality` VARCHAR(80)
- `created_at` TIMESTAMP

### publishers
- `publisher_id` INT **PK**
- `publisher_name` VARCHAR(150) NOT NULL **UQ**
- `address` VARCHAR(255)
- `website` VARCHAR(255)
- `created_at` TIMESTAMP

### categories
- `category_id` INT **PK**
- `category_name` VARCHAR(100) NOT NULL **UQ**
- `description` TEXT
- `parent_category_id` INT **FK** → `categories.category_id` (nullable)

### books
- `book_id` INT **PK**
- `publisher_id` INT **FK** → `publishers.publisher_id`
- `title` VARCHAR(255) NOT NULL
- `isbn` VARCHAR(20) NOT NULL **UQ**
- `price` DECIMAL(10,2) NOT NULL
- `stock` INT NOT NULL
- `publication_date` DATE
- `description` TEXT
- `created_at` TIMESTAMP

### book_authors
- `book_id` INT **PK, FK** → `books.book_id`
- `author_id` INT **PK, FK** → `authors.author_id`
- `author_order` TINYINT UNSIGNED

### book_categories
- `book_id` INT **PK, FK** → `books.book_id`
- `category_id` INT **PK, FK** → `categories.category_id`

### customers
- `customer_id` INT **PK**
- `full_name` VARCHAR(150) NOT NULL
- `email` VARCHAR(190) NOT NULL **UQ**
- `password_hash` VARCHAR(255) NOT NULL
- `phone` VARCHAR(25)
- `address` VARCHAR(255)
- `created_at` TIMESTAMP

### orders
- `order_id` INT **PK**
- `customer_id` INT **FK** → `customers.customer_id`
- `order_date` DATETIME
- `status` ENUM NOT NULL DEFAULT 'pending'
- `total_amount` DECIMAL(10,2) NOT NULL
- `shipping_address` VARCHAR(255) NOT NULL

### order_items
- `order_item_id` INT **PK**
- `order_id` INT **FK** → `orders.order_id`
- `book_id` INT **FK** → `books.book_id`
- `quantity` INT NOT NULL
- `unit_price` DECIMAL(10,2) NOT NULL
- `subtotal` DECIMAL(10,2) NOT NULL
- UNIQUE (`order_id`, `book_id`)

### reviews
- `review_id` INT **PK**
- `customer_id` INT **FK** → `customers.customer_id`
- `book_id` INT **FK** → `books.book_id`
- `rating` TINYINT NOT NULL (1–5)
- `comment` TEXT
- `review_date` DATETIME
- UNIQUE (`customer_id`, `book_id`)

## 2. Relationships and cardinality

```text
publishers  ||---------o{ books             (one publisher publishes many books)
books       ||---------o{ book_authors      (one book has one or more author links)
authors     ||---------o{ book_authors      (one author can link to many books)
books       ||---------o{ book_categories   (one book can have many category links)
categories  ||---------o{ book_categories   (one category can contain many books)
categories  o|---------o{ categories        (a parent category can have subcategories)
customers   ||---------o{ orders            (one customer can place many orders)
orders      ||---------|{ order_items       (one order contains one or more items)
books       ||---------o{ order_items       (one book can appear in many order items)
customers   ||---------o{ reviews           (one customer can write many reviews)
books       ||---------o{ reviews           (one book can receive many reviews)
```

`book_authors` resolves the M:N relationship between books and authors.  
`book_categories` resolves the M:N relationship between books and categories.  
`order_items` resolves the M:N relationship between orders and books while storing quantity and the price at the time of purchase.

## 3. Normalization to 3NF

- **1NF:** Each field contains one atomic value. Authors and categories are not stored as comma-separated lists; they are stored in separate linked tables.
- **2NF:** The junction tables use composite primary keys. Their non-key attributes depend on the whole key; for example, `author_order` depends on the combination of `book_id` and `author_id`.
- **3NF:** Descriptive details are stored with their own entities. Publisher details are in `publishers`, author details in `authors`, and customer details in `customers`; `books` stores only `publisher_id` as the reference. Order item price is retained as a historical transaction value, rather than relying on the book's current price.
