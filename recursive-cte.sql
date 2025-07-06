DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS product_categories CASCADE;

CREATE TABLE employees
(
    employee_id   INT PRIMARY KEY,
    employee_name VARCHAR(50) NOT NULL,
    manager_id    INT, -- References employee_id of the manager
    FOREIGN KEY (manager_id) REFERENCES employees (employee_id)
);

CREATE TABLE product_categories
(
    category_id        INT PRIMARY KEY,
    category_name      VARCHAR(50) NOT NULL,
    parent_category_id INT, -- References category_id of the parent category
    FOREIGN KEY (parent_category_id) REFERENCES product_categories (category_id)
);

INSERT INTO employees (employee_id, employee_name, manager_id)
VALUES (1, 'Alice', NULL), -- CEO, no manager
       (2, 'Bob', 1),      -- Reports to Alice
       (3, 'Charlie', 1),  -- Reports to Alice
       (4, 'David', 2),    -- Reports to Bob
       (5, 'Emma', 2),     -- Reports to Bob
       (6, 'Fiona', 3),    -- Reports to Charlie
       (7, 'George', 3),   -- Reports to Charlie
       (8, 'Hannah', 4),   -- Reports to David
       (9, 'Ian', 4),      -- Reports to David
       (10, 'Jill', 6); -- Reports to Fiona;


INSERT INTO product_categories (category_id, category_name, parent_category_id)
VALUES (1, 'Electronics', NULL),    -- Top-level
       (2, 'Clothing', NULL),       -- Top-level
       (3, 'Home & Garden', NULL),  -- Top-level
       (4, 'Laptops', 1),           -- Under Electronics
       (5, 'Smartphones', 1),       -- Under Electronics
       (6, 'Tablets', 1),           -- Under Electronics
       (7, 'Men''s Clothing', 2),   -- Under Clothing
       (8, 'Women''s Clothing', 2), -- Under Clothing
       (9, 'Furniture', 3),         -- Under Home & Garden
       (10, 'Gardening Tools', 3),  -- Under Home & Garden
       (11, 'Gaming Laptops', 4),   -- Under Laptops
       (12, 'Ultrabooks', 4),       -- Under Laptops
       (13, 'Shirts', 7),           -- Under Men's Clothing
       (14, 'Dresses', 8),          -- Under Women's Clothing
       (15, 'Outdoor Furniture', 9);
-- Under Furniture

-- 1. Generate even numbers up to 20
WITH RECURSIVE even_numbers AS (SELECT 2 AS num
                                UNION ALL
                                SELECT num + 2
                                FROM even_numbers
                                WHERE num < 20)
SELECT *
FROM even_numbers;

-- 2. Show hierarchy levels under Bob
WITH RECURSIVE bob_cte AS (SELECT e.employee_id, e.employee_name, e.manager_id, 0 AS level
                           FROM employees e
                           WHERE e.employee_id = 2
                           UNION ALL
                           SELECT e2.employee_id, e2.employee_name, e2.manager_id, bc.level + 1
                           FROM employees e2
                                    JOIN bob_cte bc ON bc.employee_id = e2.manager_id)
SELECT *
FROM bob_cte
ORDER BY level, employee_name;


-- 3. List All Categories Under 'Electronics'
WITH RECURSIVE under_category_cte AS (SELECT c.category_id, c.category_name, c.parent_category_id, 0 AS level
                                      FROM product_categories c
                                      WHERE c.category_id = 1
                                      UNION ALL
                                      SELECT c1.category_id, c1.category_name, c1.parent_category_id, ucc.level + 1
                                      FROM product_categories c1
                                               JOIN under_category_cte ucc ON ucc.category_id = c1.parent_category_id)
SELECT *
FROM under_category_cte
ORDER BY level, category_name;


-- 4. List All Top-Level Categories and Their Immediate Children
WITH RECURSIVE tl_cte AS (SELECT pc.category_id, pc.category_name, pc.parent_category_id, 0 AS level
                          FROM product_categories pc
                          WHERE parent_category_id IS NULL
                          UNION ALL
                          SELECT pc2.category_id, pc2.category_name, pc2.parent_category_id, tl.level + 1
                          FROM product_categories pc2
                                   JOIN tl_cte tl ON tl.category_id = pc2.parent_category_id
                          WHERE tl.level = 0)
SELECT *
FROM tl_cte
ORDER BY level, category_name;


-- 5. List All Categories Under 'Clothing'
WITH RECURSIVE tl_cte AS (SELECT pc.category_id, pc.category_name, pc.parent_category_id
                          FROM product_categories pc
                          WHERE category_id = 2
                          UNION ALL
                          SELECT pc2.category_id, pc2.category_name, pc2.parent_category_id
                          FROM product_categories pc2
                                   JOIN tl_cte tl ON tl.category_id = pc2.parent_category_id)
SELECT *
FROM tl_cte
ORDER BY category_id;


-- 6. Count Categories Under 'Home & Garden'
WITH RECURSIVE tl_cte AS (SELECT pc.category_id, pc.category_name, pc.parent_category_id
                          FROM product_categories pc
                          WHERE category_id = 3
                          UNION ALL
                          SELECT pc2.category_id, pc2.category_name, pc2.parent_category_id
                          FROM product_categories pc2
                                   JOIN tl_cte tl ON tl.category_id = pc2.parent_category_id)
SELECT COUNT(*)
FROM tl_cte;


-- 7. Show Category and Parent Category Names
WITH RECURSIVE tl_cte AS (SELECT pc.category_id, pc.category_name, pc.parent_category_id
                          FROM product_categories pc
                          WHERE parent_category_id IS NULL
                          UNION ALL
                          SELECT pc2.category_id, pc2.category_name, pc2.parent_category_id
                          FROM product_categories pc2
                                   JOIN tl_cte tl ON tl.category_id = pc2.parent_category_id)
SELECT tc.*,
       (CASE
            WHEN pc.category_name IS NOT NULL THEN pc.category_name
            ELSE 'No parent category' END) AS parent_category_name
FROM tl_cte tc
         LEFT JOIN product_categories pc ON tc.parent_category_id = pc.category_id;


-- 8. Generate a path for each employee
WITH RECURSIVE hierarchy_cte AS (SELECT e.employee_id,
                                        e.employee_name,
                                        e.manager_id,
                                        e.employee_name::CHARACTER VARYING AS path
                                 FROM employees e
                                 WHERE manager_id IS NULL
                                 UNION ALL
                                 SELECT e2.employee_id,
                                        e2.employee_name,
                                        e2.manager_id,
                                        CONCAT(path, ' -> ', e2.employee_name)
                                 FROM employees e2
                                          JOIN hierarchy_cte bc ON bc.employee_id = e2.manager_id)
SELECT *
FROM hierarchy_cte
ORDER BY employee_name;



