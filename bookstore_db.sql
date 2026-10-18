-- INS3064 Homework 6: Online Bookstore Database
-- Student: Phan Thi Ngoc Anh
-- MySQL / MariaDB compatible; InnoDB and utf8mb4.
-- Normalization to 3NF:
-- 1NF: every column stores one atomic value; repeating author/category lists are separated.
-- 2NF: junction tables use composite keys and their non-key attributes depend on the whole key.
-- 3NF: author, publisher, category, customer, book, order and review facts are kept in their
--      own tables; non-key attributes do not depend on other non-key attributes.
--      order_items.unit_price records the historical purchase price.

CREATE DATABASE IF NOT EXISTS bookstore_db
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bookstore_db;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS book_categories;
DROP TABLE IF EXISTS book_authors;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS authors;
DROP TABLE IF EXISTS publishers;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE authors (
    author_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    author_name VARCHAR(150) NOT NULL,
    biography TEXT,
    nationality VARCHAR(80),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE publishers (
    publisher_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    publisher_name VARCHAR(150) NOT NULL,
    address VARCHAR(255),
    website VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_publishers_name UNIQUE (publisher_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE categories (
    category_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    description TEXT,
    parent_category_id INT UNSIGNED NULL,
    CONSTRAINT uq_categories_name UNIQUE (category_name),
    CONSTRAINT fk_categories_parent FOREIGN KEY (parent_category_id)
        REFERENCES categories(category_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE books (
    book_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    publisher_id INT UNSIGNED NOT NULL,
    title VARCHAR(255) NOT NULL,
    isbn VARCHAR(20) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INT UNSIGNED NOT NULL DEFAULT 0,
    publication_date DATE,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_books_isbn UNIQUE (isbn),
    CONSTRAINT chk_books_price CHECK (price > 0),
    CONSTRAINT fk_books_publisher FOREIGN KEY (publisher_id)
        REFERENCES publishers(publisher_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE book_authors (
    book_id INT UNSIGNED NOT NULL,
    author_id INT UNSIGNED NOT NULL,
    author_order TINYINT UNSIGNED NOT NULL DEFAULT 1,
    PRIMARY KEY (book_id, author_id),
    CONSTRAINT fk_book_authors_book FOREIGN KEY (book_id)
        REFERENCES books(book_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_book_authors_author FOREIGN KEY (author_id)
        REFERENCES authors(author_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE book_categories (
    book_id INT UNSIGNED NOT NULL,
    category_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (book_id, category_id),
    CONSTRAINT fk_book_categories_book FOREIGN KEY (book_id)
        REFERENCES books(book_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_book_categories_category FOREIGN KEY (category_id)
        REFERENCES categories(category_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE customers (
    customer_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(190) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(25),
    address VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_customers_email UNIQUE (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE orders (
    order_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id INT UNSIGNED NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending','processing','shipped','delivered','cancelled')
        NOT NULL DEFAULT 'pending',
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    shipping_address VARCHAR(255) NOT NULL,
    CONSTRAINT chk_orders_total CHECK (total_amount >= 0),
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE order_items (
    order_item_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id INT UNSIGNED NOT NULL,
    book_id INT UNSIGNED NOT NULL,
    quantity INT UNSIGNED NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    CONSTRAINT uq_order_book UNIQUE (order_id, book_id),
    CONSTRAINT chk_order_items_quantity CHECK (quantity > 0),
    CONSTRAINT chk_order_items_price CHECK (unit_price > 0),
    CONSTRAINT chk_order_items_subtotal CHECK (subtotal >= 0),
    CONSTRAINT fk_order_items_order FOREIGN KEY (order_id)
        REFERENCES orders(order_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_order_items_book FOREIGN KEY (book_id)
        REFERENCES books(book_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE reviews (
    review_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id INT UNSIGNED NOT NULL,
    book_id INT UNSIGNED NOT NULL,
    rating TINYINT UNSIGNED NOT NULL,
    comment TEXT,
    review_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_review_customer_book UNIQUE (customer_id, book_id),
    CONSTRAINT chk_reviews_rating CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT fk_reviews_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_reviews_book FOREIGN KEY (book_id)
        REFERENCES books(book_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4 publishers
INSERT INTO publishers (publisher_name, address, website) VALUES
('Knowledge House Publishing', '12 Le Loi Street, Hanoi', 'https://example.com/knowledge'),
('Riverbank Books', '25 Tran Hung Dao Street, Hanoi', 'https://example.com/riverbank'),
('Bright Future Press', '8 Nguyen Hue Street, Ho Chi Minh City', 'https://example.com/bright'),
('Global Learning Media', '41 Hai Ba Trung Street, Da Nang', 'https://example.com/global');

-- 6 authors
INSERT INTO authors (author_name, biography, nationality) VALUES
('Nguyen Minh An', 'Writer of introductory technology books.', 'Vietnamese'),
('Tran Thu Ha', 'Author focusing on business and management.', 'Vietnamese'),
('Le Quang Huy', 'Writer and software practitioner.', 'Vietnamese'),
('Mai Lan Phuong', 'Author of contemporary fiction.', 'Vietnamese'),
('James Clearfield', 'Writer on habits and personal productivity.', 'American'),
('Sarah Miller', 'Researcher and author of data literacy books.', 'British');

-- 5 categories
INSERT INTO categories (category_name, description, parent_category_id) VALUES
('Technology', 'Computing, software and digital technology.', NULL),
('Business', 'Business, economics and management.', NULL),
('Fiction', 'Fiction and imaginative stories.', NULL),
('Personal Development', 'Learning, habits and self-improvement.', NULL),
('Database', 'Database concepts and data management.', 1);

-- 8 books
INSERT INTO books (publisher_id, title, isbn, price, stock, publication_date, description) VALUES
(1, 'Database Design for Beginners', '9780000000001', 185000.00, 25, '2024-03-15', 'A practical introduction to relational database design.'),
(3, 'Learning SQL Step by Step', '9780000000002', 210000.00, 18, '2023-08-20', 'SQL fundamentals with examples.'),
(2, 'Digital Business Essentials', '9780000000003', 175000.00, 30, '2024-01-10', 'An introduction to digital business.'),
(1, 'Introduction to Web Development', '9780000000004', 230000.00, 14, '2024-06-05', 'A beginner-friendly web development guide.'),
(4, 'The Quiet River', '9780000000005', 120000.00, 40, '2022-11-12', 'A contemporary Vietnamese-inspired novel.'),
(2, 'Build Better Habits', '9780000000006', 160000.00, 22, '2023-04-18', 'Practical ideas for improving everyday habits.'),
(3, 'Data Literacy at Work', '9780000000007', 195000.00, 16, '2024-02-25', 'Understand and communicate with data.'),
(4, 'Managing Small Projects', '9780000000008', 155000.00, 20, '2023-09-30', 'A concise guide to project management.');

-- M:N book-author links
INSERT INTO book_authors (book_id, author_id, author_order) VALUES
(1, 3, 1), (1, 6, 2),
(2, 3, 1), (2, 1, 2),
(3, 2, 1), (4, 1, 1),
(5, 4, 1), (6, 5, 1),
(7, 6, 1), (8, 2, 1), (8, 3, 2);

-- M:N book-category links
INSERT INTO book_categories (book_id, category_id) VALUES
(1, 1), (1, 5), (2, 1), (2, 5),
(3, 2), (4, 1), (5, 3), (6, 4),
(7, 1), (7, 2), (8, 2);

-- 5 customers; sample password_hash values are placeholders for coursework only.
INSERT INTO customers (full_name, email, password_hash, phone, address) VALUES
('Nguyen Mai Anh', 'maianh@example.com', 'demo_hash_01', '0901000001', 'Cau Giay, Hanoi'),
('Tran Duc Long', 'duclong@example.com', 'demo_hash_02', '0901000002', 'Dong Da, Hanoi'),
('Le Khanh Linh', 'khanhlinh@example.com', 'demo_hash_03', '0901000003', 'Hai Chau, Da Nang'),
('Pham Gia Bao', 'giabao@example.com', 'demo_hash_04', '0901000004', 'Thu Duc, Ho Chi Minh City'),
('Do Thu Trang', 'thutrang@example.com', 'demo_hash_05', '0901000005', 'Thanh Xuan, Hanoi');

-- 6 orders
INSERT INTO orders (customer_id, order_date, status, total_amount, shipping_address) VALUES
(1, '2026-10-01 09:30:00', 'delivered', 395000.00, 'Cau Giay, Hanoi'),
(2, '2026-10-02 14:15:00', 'shipped', 330000.00, 'Dong Da, Hanoi'),
(3, '2026-10-03 10:00:00', 'processing', 405000.00, 'Hai Chau, Da Nang'),
(4, '2026-10-04 16:20:00', 'pending', 350000.00, 'Thu Duc, Ho Chi Minh City'),
(5, '2026-10-05 11:45:00', 'delivered', 385000.00, 'Thanh Xuan, Hanoi'),
(1, '2026-10-06 18:05:00', 'processing', 385000.00, 'Cau Giay, Hanoi');

-- 12 order items; subtotal = quantity * unit_price
INSERT INTO order_items (order_id, book_id, quantity, unit_price, subtotal) VALUES
(1, 1, 1, 185000.00, 185000.00), (1, 2, 1, 210000.00, 210000.00),
(2, 3, 1, 175000.00, 175000.00), (2, 6, 1, 155000.00, 155000.00),
(3, 4, 1, 230000.00, 230000.00), (3, 5, 1, 120000.00, 120000.00),
(3, 6, 1, 55000.00, 55000.00),
(4, 2, 1, 210000.00, 210000.00), (4, 8, 1, 140000.00, 140000.00),
(5, 1, 1, 185000.00, 185000.00), (5, 7, 1, 200000.00, 200000.00),
(6, 3, 1, 175000.00, 175000.00), (6, 7, 1, 210000.00, 210000.00);

-- 10 reviews; one review per customer/book pair.
INSERT INTO reviews (customer_id, book_id, rating, comment, review_date) VALUES
(1, 1, 5, 'Clear explanation and useful examples.', '2026-10-07 09:00:00'),
(2, 2, 4, 'Helpful for practicing SQL.', '2026-10-07 10:00:00'),
(3, 3, 4, 'Easy to follow.', '2026-10-07 11:00:00'),
(4, 4, 5, 'Good introduction for beginners.', '2026-10-07 12:00:00'),
(5, 5, 4, 'An enjoyable story.', '2026-10-07 13:00:00'),
(1, 6, 5, 'Practical suggestions.', '2026-10-08 09:00:00'),
(2, 7, 4, 'A useful overview of data.', '2026-10-08 10:00:00'),
(3, 8, 3, 'Good summary of project basics.', '2026-10-08 11:00:00'),
(4, 1, 5, 'The database examples are clear.', '2026-10-08 12:00:00'),
(5, 2, 4, 'Useful reference material.', '2026-10-08 13:00:00');

-- Verification queries: run after importing to confirm the schema and sample data.
SHOW TABLES;
SELECT 'authors' AS table_name, COUNT(*) AS row_count FROM authors
UNION ALL SELECT 'publishers', COUNT(*) FROM publishers
UNION ALL SELECT 'categories', COUNT(*) FROM categories
UNION ALL SELECT 'books', COUNT(*) FROM books
UNION ALL SELECT 'book_authors', COUNT(*) FROM book_authors
UNION ALL SELECT 'book_categories', COUNT(*) FROM book_categories
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'reviews', COUNT(*) FROM reviews;
