-- INS3064 Homework 7: Advanced SQL
-- Student: Phan Thi Ngoc Anh
-- Student ID: 22070513
-- Date: 2026-10-25
-- Database: bookstore_db (created in Homework 6)

USE bookstore_db;

-- Query 1: List every book with its ISBN and author name.
SELECT
    b.title AS book_title,
    b.isbn,
    a.author_name
FROM books AS b
INNER JOIN book_authors AS ba ON b.book_id = ba.book_id
INNER JOIN authors AS a ON ba.author_id = a.author_id
ORDER BY b.title, ba.author_order;

/*
Expected output (sample):
+----------------------------------+---------------+----------------+
| book_title                       | isbn          | author_name    |
+----------------------------------+---------------+----------------+
| Database Design for Beginners    | 9780000000001 | Le Quang Huy   |
| Database Design for Beginners    | 9780000000001 | Sarah Miller   |
| Learning SQL Step by Step        | 9780000000002 | Le Quang Huy   |
| Learning SQL Step by Step        | 9780000000002 | Nguyen Minh An |
+----------------------------------+---------------+----------------+
Each book appears once per linked author.
*/

-- Query 2: Show order details with customer, date, book, quantity, and line total.
SELECT
    o.order_id,
    c.full_name AS customer_name,
    o.order_date,
    b.title AS book_title,
    oi.quantity,
    oi.quantity * oi.unit_price AS line_total
FROM orders AS o
INNER JOIN customers AS c ON o.customer_id = c.customer_id
INNER JOIN order_items AS oi ON o.order_id = oi.order_id
INNER JOIN books AS b ON oi.book_id = b.book_id
ORDER BY o.order_date DESC, o.order_id DESC;

/*
Expected output (sample):
+----------+----------------+---------------------+----------------------------+----------+------------+
| order_id | customer_name  | order_date          | book_title                 | quantity | line_total |
+----------+----------------+---------------------+----------------------------+----------+------------+
| 6        | Nguyen Mai Anh | 2026-10-06 18:05:00 | Digital Business Essentials| 1        | 175000.00  |
| 6        | Nguyen Mai Anh | 2026-10-06 18:05:00 | Data Literacy at Work      | 1        | 210000.00  |
| 5        | Do Thu Trang   | 2026-10-05 11:45:00 | Database Design for Beginners| 1      | 185000.00  |
+----------+----------------+---------------------+----------------------------+----------+------------+
The line_total column is quantity multiplied by the recorded unit_price.
*/

-- Query 3: List each book with its publisher and category names.
SELECT
    b.title AS book_title,
    p.publisher_name,
    c.category_name
FROM books AS b
INNER JOIN publishers AS p ON b.publisher_id = p.publisher_id
LEFT JOIN book_categories AS bc ON b.book_id = bc.book_id
LEFT JOIN categories AS c ON bc.category_id = c.category_id
ORDER BY b.title, c.category_name;

/*
Expected output (sample):
+----------------------------------+--------------------------+----------------+
| book_title                       | publisher_name           | category_name  |
+----------------------------------+--------------------------+----------------+
| Database Design for Beginners    | Knowledge House Publishing| Database      |
| Database Design for Beginners    | Knowledge House Publishing| Technology    |
| Digital Business Essentials      | Riverbank Books          | Business       |
| The Quiet River                  | Global Learning Media    | Fiction        |
+----------------------------------+--------------------------+----------------+
Books with multiple categories appear on multiple rows.
*/

-- Query 4: Calculate the total quantity sold and total revenue for each book.
SELECT
    b.title AS book_title,
    COALESCE(SUM(oi.quantity), 0) AS total_quantity_sold,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0.00) AS total_revenue
FROM books AS b
LEFT JOIN order_items AS oi ON b.book_id = oi.book_id
GROUP BY b.book_id, b.title
ORDER BY total_revenue DESC, b.title;

/*
Expected output (sample):
+----------------------------+--------------------+--------------+
| book_title                 | total_quantity_sold| total_revenue|
+----------------------------+--------------------+--------------+
| Learning SQL Step by Step  | 2                  | 420000.00    |
| Data Literacy at Work      | 2                  | 410000.00    |
| Database Design for Beginners| 2                 | 370000.00    |
+----------------------------+--------------------+--------------+
All books are included; books without sales show 0.
*/

-- Query 5: Summarize each customer's order count and total amount spent.
SELECT
    c.customer_id,
    c.full_name AS customer_name,
    COUNT(o.order_id) AS order_count,
    COALESCE(SUM(o.total_amount), 0.00) AS total_amount_spent
FROM customers AS c
LEFT JOIN orders AS o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY total_amount_spent DESC, c.full_name;

/*
Expected output (sample):
+-------------+----------------+-------------+--------------------+
| customer_id | customer_name  | order_count | total_amount_spent |
+-------------+----------------+-------------+--------------------+
| 1           | Nguyen Mai Anh | 2           | 780000.00          |
| 3           | Le Khanh Linh  | 1           | 405000.00          |
| 5           | Do Thu Trang   | 1           | 385000.00          |
+-------------+----------------+-------------+--------------------+
Customers with no orders remain in the result with 0 orders and 0.00 spent.
*/

-- Query 6: Find books whose prices are higher than the average book price.
SELECT
    title AS book_title,
    price
FROM books
WHERE price > (
    SELECT AVG(price)
    FROM books
)
ORDER BY price DESC, title;

/*
Expected output (sample):
+-------------------------------+-----------+
| book_title                    | price     |
+-------------------------------+-----------+
| Introduction to Web Development| 230000.00|
| Learning SQL Step by Step     | 210000.00 |
| Data Literacy at Work         | 195000.00 |
+-------------------------------+-----------+
Only books priced above the average price are returned.
*/

-- Query 7: Find every author tied for the highest total quantity of books sold.
SELECT
    author_sales.author_name,
    author_sales.total_quantity_sold
FROM (
    SELECT
        a.author_id,
        a.author_name,
        COALESCE(SUM(oi.quantity), 0) AS total_quantity_sold
    FROM authors AS a
    LEFT JOIN book_authors AS ba ON a.author_id = ba.author_id
    LEFT JOIN order_items AS oi ON ba.book_id = oi.book_id
    GROUP BY a.author_id, a.author_name
) AS author_sales
WHERE author_sales.total_quantity_sold = (
    SELECT MAX(sales_by_author.total_quantity_sold)
    FROM (
        SELECT
            a2.author_id,
            COALESCE(SUM(oi2.quantity), 0) AS total_quantity_sold
        FROM authors AS a2
        LEFT JOIN book_authors AS ba2 ON a2.author_id = ba2.author_id
        LEFT JOIN order_items AS oi2 ON ba2.book_id = oi2.book_id
        GROUP BY a2.author_id
    ) AS sales_by_author
)
ORDER BY author_sales.author_name;

/*
Expected output (sample):
+----------------+--------------------+
| author_name    | total_quantity_sold|
+----------------+--------------------+
| Le Quang Huy   | 5                  |
+----------------+--------------------+
The subquery compares each author's total with the maximum, so ties are included.
*/

-- Query 8: Find customers with more than two reviews rated 3 or higher.
SELECT
    c.full_name AS customer_name,
    COUNT(r.review_id) AS review_count
FROM customers AS c
INNER JOIN reviews AS r ON c.customer_id = r.customer_id
WHERE r.rating >= 3
GROUP BY c.customer_id, c.full_name
HAVING COUNT(r.review_id) > 2
ORDER BY review_count DESC, customer_name;

/*
Expected output:
No rows are expected with the current Homework 6 sample data.
A customer will appear when they have written more than two reviews with ratings >= 3.
*/

-- Query 9: Create a reusable summary view for sales and review information per book.
CREATE OR REPLACE VIEW v_book_sales_summary AS
SELECT
    b.title AS book_title,
    b.isbn,
    p.publisher_name,
    COALESCE(sales.total_quantity_sold, 0) AS total_quantity_sold,
    COALESCE(sales.total_revenue, 0.00) AS total_revenue,
    reviews.average_review_rating,
    COALESCE(reviews.number_of_reviews, 0) AS number_of_reviews
FROM books AS b
INNER JOIN publishers AS p ON b.publisher_id = p.publisher_id
LEFT JOIN (
    SELECT
        book_id,
        SUM(quantity) AS total_quantity_sold,
        SUM(quantity * unit_price) AS total_revenue
    FROM order_items
    GROUP BY book_id
) AS sales ON b.book_id = sales.book_id
LEFT JOIN (
    SELECT
        book_id,
        AVG(rating) AS average_review_rating,
        COUNT(review_id) AS number_of_reviews
    FROM reviews
    GROUP BY book_id
) AS reviews ON b.book_id = reviews.book_id;

-- Display the view to verify it works.
SELECT
    book_title,
    isbn,
    publisher_name,
    total_quantity_sold,
    total_revenue,
    average_review_rating,
    number_of_reviews
FROM v_book_sales_summary
ORDER BY book_title;

/*
Expected output (sample):
+-------------------------------+---------------+--------------------------+--------------------+--------------+-----------------------+------------------+
| book_title                    | isbn          | publisher_name           | total_quantity_sold| total_revenue| average_review_rating | number_of_reviews|
+-------------------------------+---------------+--------------------------+--------------------+--------------+-----------------------+------------------+
| Database Design for Beginners | 9780000000001 | Knowledge House Publishing| 2                 | 370000.00    | 5.00                  | 2                |
| Learning SQL Step by Step     | 9780000000002 | Bright Future Press      | 2                 | 420000.00    | 4.00                  | 2                |
+-------------------------------+---------------+--------------------------+--------------------+--------------+-----------------------+------------------+
Books without sales show 0; books without reviews show NULL for average rating and 0 for review count.
*/

-- Query 10: Report monthly order count, items sold, and revenue for every month of the current year.
WITH RECURSIVE months AS (
    SELECT 1 AS month_number
    UNION ALL
    SELECT month_number + 1
    FROM months
    WHERE month_number < 12
),
monthly_totals AS (
    SELECT
        MONTH(o.order_date) AS month_number,
        COUNT(DISTINCT o.order_id) AS number_of_orders,
        COALESCE(SUM(oi.quantity), 0) AS total_items_sold,
        COALESCE(SUM(oi.quantity * oi.unit_price), 0.00) AS total_revenue
    FROM orders AS o
    LEFT JOIN order_items AS oi ON o.order_id = oi.order_id
    WHERE YEAR(o.order_date) = YEAR(CURDATE())
    GROUP BY MONTH(o.order_date)
)
SELECT
    m.month_number,
    MONTHNAME(
    STR_TO_DATE(
        CONCAT(m.month_number, '-01-2000'),
        '%m-%d-%Y'
    )
) AS month_name,
    COALESCE(mt.number_of_orders, 0) AS number_of_orders,
    COALESCE(mt.total_items_sold, 0) AS total_items_sold,
    COALESCE(mt.total_revenue, 0.00) AS total_revenue
FROM months AS m
LEFT JOIN monthly_totals AS mt ON m.month_number = mt.month_number
ORDER BY m.month_number;

/*
Expected output (sample, based on the Homework 6 data and current year 2026):
+--------------+------------+------------------+-----------------+--------------+
| month_number | month_name | number_of_orders | total_items_sold| total_revenue|
+--------------+------------+------------------+-----------------+--------------+
| 1            | January    | 0                | 0               | 0.00         |
| 2            | February   | 0                | 0               | 0.00         |
| ...          | ...        | ...              | ...             | ...          |
| 10           | October    | 6                | 13              | 2250000.00   |
| 11           | November   | 0                | 0               | 0.00         |
| 12           | December   | 0                | 0               | 0.00         |
+--------------+------------+------------------+-----------------+--------------+
All 12 months are shown, including months with no orders.
*/
