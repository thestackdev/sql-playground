DROP TABLE IF EXISTS Customers CASCADE;
DROP TABLE IF EXISTS Orders CASCADE;
DROP TABLE IF EXISTS OrderReturns CASCADE;

CREATE TABLE IF NOT EXISTS Customers
(
    customer_id   INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email         VARCHAR(100) UNIQUE,
    join_date     DATE         NOT NULL
);

CREATE TABLE IF NOT EXISTS Orders
(
    order_id     INT PRIMARY KEY,
    customer_id  INT,
    order_date   DATE           NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    status       VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (customer_id) REFERENCES Customers (customer_id)
);

CREATE TABLE IF NOT EXISTS OrderReturns
(
    return_id     INT PRIMARY KEY,
    order_id      INT,
    return_date   DATE NOT NULL,
    reason        VARCHAR(200),
    refund_amount DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES Orders (order_id)
);


-- Insert Customers
INSERT INTO Customers (customer_id, customer_name, email, join_date)
VALUES (1, 'Alice Johnson', 'alice.j@example.com', '2023-01-15'),
       (2, 'Bob Smith', 'bob.smith@example.com', '2023-02-20'),
       (3, 'Carol White', 'carol.w@example.com', '2023-03-10'),
       (4, 'David Brown', 'david.b@example.com', '2023-04-05'),
       (5, 'Emma Davis', 'emma.d@example.com', '2023-05-12'),
       (6, 'Frank Lee', 'frank.l@example.com', '2023-06-18'),
       (7, 'Grace Kim', 'grace.k@example.com', '2023-07-22'),
       (8, 'Henry Patel', 'henry.p@example.com', '2023-08-30'),
       (9, 'Isabel Chen', 'isabel.c@example.com', '2023-09-15'),
       (10, 'James Wilson', 'james.w@example.com', '2023-10-10'),
       (11, 'Kelly Adams', NULL, '2023-11-05'),
       (12, 'Liam Turner', 'liam.t@example.com', '2023-12-01'),
       (13, 'Mia Clark', 'mia.c@example.com', '2024-01-20'),
       (14, 'Noah Evans', 'noah.e@example.com', '2024-02-15'),
       (15, 'Olivia Green', 'olivia.g@example.com', '2024-03-10');

-- Insert Orders
INSERT INTO Orders (order_id, customer_id, order_date, total_amount, status)
VALUES (101, 1, '2023-02-01', 150.50, 'Delivered'),
       (102, 1, '2023-03-15', 75.20, 'Delivered'),
       (103, 2, '2023-03-05', 200.00, 'Pending'),
       (104, 3, '2023-04-10', 50.75, 'Delivered'),
       (105, 4, '2023-05-20', 300.00, 'Delivered'),
       (106, 5, '2023-06-01', 120.30, 'Cancelled'),
       (107, 6, '2023-07-15', 89.99, 'Delivered'),
       (108, 7, '2023-08-01', 45.00, 'Delivered'),
       (109, 8, '2023-09-10', 250.00, 'Pending'),
       (110, 9, '2023-10-05', 99.99, 'Delivered'),
       (111, 1, '2023-11-20', 180.25, 'Delivered'),
       (112, 3, '2023-12-15', 65.40, 'Delivered'),
       (113, 5, '2024-01-10', 110.00, 'Delivered'),
       (114, 10, '2024-02-01', 320.50, 'Delivered'),
       (115, 12, '2024-03-05', 95.75, 'Pending');

-- Insert OrderReturns
INSERT INTO OrderReturns (return_id, order_id, return_date, reason, refund_amount)
VALUES (201, 101, '2023-02-10', 'Defective product', 150.50),
       (202, 104, '2023-04-15', 'Wrong item shipped', 50.75),
       (203, 106, '2023-06-10', 'Customer changed mind', 120.30),
       (204, 108, '2023-08-10', 'Damaged during shipping', 45.00),
       (205, 111, '2023-11-30', 'Defective product', 90.00),
       (206, 113, '2024-01-20', 'Not as described', 55.00);


-- 1: Find Customers with Orders
SELECT *
FROM customers c
WHERE EXISTS(SELECT 1
             FROM orders o
             WHERE o.customer_id = c.customer_id);

-- 2: Find Customers with No Orders
SELECT *
FROM customers c
WHERE NOT EXISTS(SELECT 1
                 FROM orders o
                 WHERE o.customer_id = c.customer_id);


-- 3. Find customers who have placed at least one order over $200 but have no orders that were returned.
SELECT *
FROM customers c
WHERE EXISTS (SELECT 1 FROM orders o WHERE o.total_amount > 200 AND o.customer_id = c.customer_id)
  AND NOT EXISTS(SELECT 1
                 FROM orderreturns r
                          JOIN orders o ON o.order_id = r.order_id
                 WHERE o.customer_id = c.customer_id);

-- 4. Find delivered orders placed in 2024 that have not been returned and belong to customers who joined before 2024.
SELECT o.order_id, o.order_date, o.total_amount
FROM orders o
         JOIN customers c ON c.customer_id = o.customer_id
WHERE o.order_date BETWEEN '2024-01-01' AND '2025-01-01'
  AND c.join_date < '2024-01-01'
  AND o.status = 'Delivered'
  AND NOT EXISTS(SELECT 1
                 FROM orderreturns r
                 WHERE r.order_id = o.order_id);


-- 5. Find customers where every order they placed has been returned.
SELECT *
FROM customers c
WHERE EXISTS(SELECT 1
             FROM orders o
             WHERE o.customer_id = c.customer_id)
  AND NOT EXISTS(SELECT 1
                 FROM orders o
                 WHERE c.customer_id = o.customer_id
                   AND NOT EXISTS(SELECT 1
                                  FROM orderreturns r
                                  WHERE r.order_id = o.order_id));

-- 6. Find customers who joined before 2023-06-01 and have at least one order over $150 in 2023, but none of their orders in 2023 were returned.
SELECT c.*
FROM customers c
WHERE c.join_date < '2023-06-01'
  AND EXISTS(SELECT 1
             FROM orders o
             WHERE o.total_amount > 150
               AND o.customer_id = c.customer_id
               AND EXTRACT(YEAR FROM o.order_date) = 2023)
  AND NOT EXISTS(SELECT 1
                 FROM orderreturns r
                          JOIN orders o ON o.order_id = r.order_id
                 WHERE o.customer_id = c.customer_id
                   AND EXTRACT(YEAR FROM o.order_date) = 2023);

-- 7. List orders with status ‘Pending’ for customers who have at least one delivered order in the past.
SELECT *
FROM orders o
         JOIN customers c ON c.customer_id = o.customer_id
WHERE status = 'Pending'
  AND EXISTS(SELECT 1
             FROM orders o2
             WHERE o2.status = 'Delivered'
               AND o2.customer_id = c.customer_id);


-- 8. Find customers who have placed orders but have no returns with a refund amount over $100.
SELECT *
FROM customers c
WHERE EXISTS(SELECT 1
             FROM orders o
             WHERE o.customer_id = c.customer_id)
  AND NOT EXISTS(SELECT 1
                 FROM orderreturns r
                          JOIN orders o ON o.order_id = r.order_id
                 WHERE o.customer_id = c.customer_id
                   AND r.refund_amount > 100);

-- 9. Find orders from customers who have exactly one order in the system.
SELECT order_id, customer_id, order_date, total_amount, status
FROM (SELECT *, COUNT(*) OVER (PARTITION BY customer_id) AS rn
      FROM orders) ft
WHERE rn = 1;


-- 10. Identify customers who have returned at least one order but have at least one delivered order that was not returned.
SELECT *
FROM customers c
WHERE EXISTS(SELECT 1
             FROM orderreturns r
                      JOIN orders o ON o.order_id = r.order_id
             WHERE c.customer_id = o.customer_id)
  AND EXISTS(SELECT 1
             FROM orders o
             WHERE o.customer_id = c.customer_id
               AND status = 'Delivered'
               AND NOT EXISTS(SELECT 1
                              FROM orderreturns r
                              WHERE r.order_id = o.order_id));


-- 11. Find customers who placed at least three orders in 2023, and at least 50% of those orders were returned. Return the customer’s name, email, total orders in 2023, and number of returned orders.
SELECT c.customer_name, c.email, COUNT(o.order_id), COUNT(r.order_id)
FROM orders o
         LEFT JOIN customers c ON o.customer_id = c.customer_id
         LEFT JOIN orderreturns r ON r.order_id = o.order_id
WHERE o.order_date BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY c.customer_name, c.email
HAVING COUNT(o.order_id) >= COUNT(o.order_id) / 2
   AND COUNT(o.order_id) >= 3;

-- 12. List orders (order_id, order_date, total_amount) from customers who have at least one other non-returned order with a total_amount over $200. Exclude orders that were returned.
SELECT o.order_id, o.order_date, o.total_amount
FROM orders o
         LEFT JOIN customers c ON c.customer_id = o.customer_id
WHERE o.status = 'Delivered'
  AND NOT EXISTS(SELECT 1
                 FROM orderreturns r
                 WHERE r.order_id = o.order_id)
  AND EXISTS(SELECT 1
             FROM orders o2
             WHERE o2.total_amount >= 200
               AND o2.customer_id = c.customer_id
               AND NOT EXISTS(SELECT 1
                              FROM orderreturns r2
                              WHERE r2.order_id = o2.order_id));

-- 13. Find customers who joined before 2023 and have no orders or returns after 2023-12-31. Return customer_name and join_date.
SELECT c.customer_name, c.join_date
FROM customers c
WHERE c.join_date < '2023-01-01'
  AND NOT EXISTS(SELECT 1
                 FROM orders o
                 WHERE o.order_date > '2023-12-31'
                   AND c.customer_id = o.order_id)
  AND NOT EXISTS(SELECT 1
                 FROM orderreturns r
                          JOIN orders o ON o.order_id = r.order_id
                 WHERE r.return_date > '2023-12-31'
                   AND c.customer_id = o.customer_id);


-- 14. Identify customers who have at least one pending order but no delivered or cancelled orders. Return customer_name and email.
SELECT c.customer_name, c.email
FROM customers c
WHERE EXISTS(SELECT 1 FROM orders o WHERE status = 'Pending' AND c.customer_id = o.customer_id)
  AND NOT EXISTS(SELECT 1
                 FROM orders o
                 WHERE status IN ('Delivered', 'Cancelled') AND c.customer_id = o.customer_id);

-- 15. Find delivered orders placed in 2024 where the customer has at least one return in the last 6 months (from July 5, 2025, backward to January 5, 2025). Return order_id, order_date, total_amount, and customer_name.
SELECT o.order_id, o.order_date, o.total_amount, c.customer_name
FROM orders o
LEFT JOIN Customers c ON c.customer_id = o.customer_id
WHERE o.status = 'Delivered'
AND EXTRACT(YEAR FROM o.order_date) = 2024
AND exists(
    SELECT 1 FROM orderreturns r
             JOIN orders o2 on r.order_id = o2.order_id
             WHERE r.order_id = o2.order_id
             AND c.customer_id = o2.customer_id
             AND return_date BETWEEN '2025-07-01' AND '2025-01-01'
);