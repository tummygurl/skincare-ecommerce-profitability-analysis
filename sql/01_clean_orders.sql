-- only affects clean_orders, never raw_orders
DROP TABLE IF EXISTS clean_orders;

CREATE TABLE clean_orders AS
WITH multi AS (          -- orders that carry more than one customer ID
    SELECT order_id
    FROM raw_orders
    GROUP BY order_id
    HAVING COUNT(DISTINCT customer_id) > 1
),
ranked AS (   -- number identical rows 1, 2, and so on. A number above 1 marks the probable duplicate
    SELECT r.*,
           ROW_NUMBER() OVER (
               PARTITION BY order_id, order_date, customer_id, segment, city, state,
             country, region, market, category, subcategory,
             product, quantity, sales, discount, profit
               ORDER BY row_id
           ) AS rn
    FROM raw_orders r
)
SELECT
    row_id,
    order_id,
    order_date,
    CAST(SUBSTR(order_date, 1, 4) AS INTEGER) AS order_year,
    SUBSTR(order_date, 1, 7)                  AS order_month,
    customer_id,
    segment,
    city,
    state,
    country,
    country_latitude,
    country_longitude,
    region,
    market,
    category,
    subcategory,
    product,
    quantity,
    discount,
    sales                 AS gross_sales,       -- before discount
    sales * discount      AS discount_amount,
    sales * (1 - discount) AS net_sales,        -- what the customer paid
    profit,                                     -- after discount
    CASE WHEN rn > 1 THEN 1 ELSE 0 END AS is_probable_duplicate,
    CASE WHEN order_id IN (SELECT order_id FROM multi) THEN 1 ELSE 0 END AS is_multi_customer_order
FROM ranked;