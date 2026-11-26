-- Same order, product, quantity, price etc. appearing twice (ignoring row_id).
SELECT order_id, order_date, customer_id, product, quantity, sales, discount, profit,
       COUNT(*) AS copies
FROM raw_orders
GROUP BY order_id, order_date, customer_id, city, product, quantity, sales, discount, profit
HAVING COUNT(*) > 1;


-- How many products appear under more than one category?
SELECT COUNT(*) AS products_in_multiple_categories
FROM (
    SELECT product
    FROM raw_orders
    GROUP BY product
    HAVING COUNT(DISTINCT category) > 1
);

-- Show 10 examples
SELECT product,
       COUNT(DISTINCT category) AS n_categories,
       GROUP_CONCAT(DISTINCT category) AS categories
FROM raw_orders
GROUP BY product
HAVING COUNT(DISTINCT category) > 1
LIMIT 10;


-- Order IDs look like IZ-2012-LW699061-40911; characters 4 to 7 are the year.
SELECT SUBSTR(order_id, 4, 4) AS id_year,
       SUBSTR(order_date, 1, 4) AS date_year,
       COUNT(*) AS rows_
FROM raw_orders
GROUP BY id_year, date_year
ORDER BY id_year;



-- For products with at least 10 rows and varying discounts, does unit price change?
SELECT product,
       COUNT(*) AS n_rows,
       MIN(discount) AS min_discount,
       MAX(discount) AS max_discount,
       ROUND(MIN(sales * 1.0 / quantity), 2) AS min_unit_price,
       ROUND(MAX(sales * 1.0 / quantity), 2) AS max_unit_price
FROM raw_orders
GROUP BY product
HAVING COUNT(*) >= 10 AND MIN(discount) <> MAX(discount)
ORDER BY n_rows DESC
LIMIT 10;


SELECT order_id, COUNT(DISTINCT customer_id) AS n_customers
FROM raw_orders
GROUP BY order_id
HAVING COUNT(DISTINCT customer_id) > 1;


