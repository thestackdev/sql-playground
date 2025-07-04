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