DROP TABLE IF EXISTS Customers CASCADE;
DROP TABLE IF EXISTS Orders CASCADE;

CREATE TABLE IF NOT EXISTS Customers
(
    CustomerID  INT PRIMARY KEY,
    FirstName   VARCHAR(50),
    LastName    VARCHAR(50),
    Email       VARCHAR(100),
    JoinDate    DATE,
    CreditLimit DECIMAL(10, 2)
);

CREATE TABLE IF NOT EXISTS Orders
(
    OrderID     INT PRIMARY KEY,
    CustomerID  INT,
    OrderDate   DATE,
    TotalAmount DECIMAL(10, 2),
    FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID)
);

INSERT INTO Customers (CustomerID, FirstName, LastName, Email, JoinDate, CreditLimit)
VALUES (1, 'John', 'Smith', 'john.smith@email.com', '2020-03-15', 5000.00),
       (2, 'Maria', 'Gonzalez', 'maria.g@email.com', '2019-07-22', 3000.50),
       (3, 'Akshay', 'Patel', NULL, '2021-01-10', 4500.75),
       (4, 'Emily', 'Brown', 'emily.brown@email.com', '2018-11-05', 2000.00),
       (5, 'Chen', 'Li', 'chen.li@email.com', '2022-06-30', NULL),
       (6, 'Sophie', 'Dubois', 'sophie.d@email.com', '2020-09-12', 6000.25),
       (7, 'Rahul', 'Sharma', 'rahul.s@email.com', '2023-02-18', 3500.00),
       (8, 'Aisha', 'Khan', NULL, '2021-08-25', 4000.00),
       (9, 'Carlos', 'Reyes', 'carlos.r@email.com', '2019-04-03', 5500.50),
       (10, 'Linda', 'Nguyen', 'linda.n@email.com', '2022-12-01', 2500.75),
       (11, 'Omar', 'Hassan', 'omar.h@email.com', '2020-05-17', 7000.00),
       (12, 'Fatima', 'Ali', 'fatima.a@email.com', '2021-03-29', 3200.00),
       (13, 'James', 'Wilson', NULL, '2018-06-14', 4800.50),
       (14, 'Anita', 'Mehta', 'anita.m@email.com', '2023-07-10', 3900.25),
       (15, 'David', 'Kim', 'david.k@email.com', '2019-10-20', 5100.00);

INSERT INTO Orders (OrderID, CustomerID, OrderDate, TotalAmount)
VALUES (1, 1, '2025-01-10', 150.99),
       (2, 1, '2025-02-20', 89.50),
       (3, 2, '2024-12-15', 299.75),
       (4, 3, '2025-03-01', 45.00),
       (5, 4, '2024-11-22', 199.99),
       (6, 5, '2025-01-05', 350.25),
       (7, 6, '2025-02-28', NULL),
       (8, 7, '2025-03-15', 75.80),
       (9, 8, '2024-10-30', 120.00),
       (10, 9, '2025-01-25', 500.50),
       (11, 10, '2025-02-10', 65.45),
       (12, 11, '2024-12-01', 250.00),
       (13, 12, '2025-03-20', 180.30),
       (14, 13, '2024-09-15', 99.99),
       (15, 14, '2025-02-05', 220.75),
       (16, 15, '2025-01-30', 310.60);


-- 1. Concatenate first and last names and convert to uppercase.
SELECT CustomerID, UPPER(CONCAT(FirstName, ' ', LastName)) AS fullName, Email, JoinDate, CreditLimit
FROM customers;

-- 2. Calculate how many years each customer has been with the company as of July 6, 2025.
SELECT CustomerID,
       UPPER(CONCAT(FirstName, ' ', LastName))        AS fullName,
       Email,
       JoinDate,
       CreditLimit,
       EXTRACT(DAYS FROM AGE(CURRENT_DATE, JoinDate)) AS days_joined
FROM customers
ORDER BY days_joined;

-- 3. Handle zero or NULL credit limits.
SELECT CustomerID,
       FirstName,
       CreditLimit,
       COALESCE(NULLIF(CreditLimit, 0), 1000.00) AS AdjustedCreditLimit
FROM Customers
LIMIT 5;

-- 4. Formatted Customer Report with JSON
SELECT CustomerID,
       JSON_BUILD_OBJECT(
               'Full Name', INITCAP(CONCAT(FirstName, ' ', LastName)),
               'Credit Limit', CreditLimit,
               'Date Joined', TO_CHAR(JoinDate, 'DD Mon YYYY')
       ) AS customer_json
FROM customers;

-- 5. GENERATE_SERIES
WITH MonthSeries AS (SELECT GENERATE_SERIES('2024-09-01'::DATE, '2025-03-01'::DATE,
                                            '1 month'::INTERVAL) AS MonthStart),
     updated_orders_date AS (SELECT OrderID,
                                    CustomerID,
                                    TO_CHAR(OrderDate, 'YYYY-MM-01') AS OrderDate,
                                    TotalAmount
                             FROM orders)
SELECT o.*
FROM MonthSeries ms
         LEFT JOIN updated_orders_date o ON o.orderdate::timestamp = ms.MonthStart
ORDER BY OrderID;