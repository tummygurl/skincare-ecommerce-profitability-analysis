WITH yearly AS (
    SELECT order_year,
           ROUND(SUM(gross_sales)) AS gross_sales,
           ROUND(SUM(net_sales))   AS net_sales,
           ROUND(SUM(profit))      AS profit,
           ROUND(100.0 * SUM(profit) / SUM(net_sales), 1) AS margin_on_net_pct
    FROM clean_orders
    WHERE is_probable_duplicate = 0
    GROUP BY order_year
)
SELECT *,
       ROUND(100.0 * (gross_sales - LAG(gross_sales) OVER (ORDER BY order_year))
             / LAG(gross_sales) OVER (ORDER BY order_year), 1) AS sales_growth_pct
FROM yearly
ORDER BY order_year;

--margin by category and year
SELECT category,
       order_year,
       ROUND(SUM(net_sales)) AS net_sales,
       ROUND(SUM(profit))    AS profit,
       ROUND(100.0 * SUM(profit) / SUM(net_sales), 1) AS margin_on_net_pct
FROM clean_orders
WHERE is_probable_duplicate = 0
GROUP BY category, order_year
ORDER BY category, order_year;


--Compares each Body care subcategory in 2022 and 2023, including how heavily it was discounted.
SELECT subcategory,
       order_year,
       ROUND(SUM(net_sales)) AS net_sales,
       ROUND(SUM(profit))    AS profit,
       ROUND(100.0 * SUM(profit) / SUM(net_sales), 1) AS margin_on_net_pct,
       ROUND(100.0 * SUM(discount_amount) / SUM(gross_sales), 1) AS discount_rate_pct
FROM clean_orders
WHERE is_probable_duplicate = 0
  AND category = 'Body care'
  AND order_year IN (2022, 2023)
GROUP BY subcategory, order_year
ORDER BY subcategory, order_year;

--
SELECT order_year,
       CASE WHEN discount = 0   THEN '1. 0%'
            WHEN discount <= 0.2 THEN '2. 1-20%'
            WHEN discount <= 0.3 THEN '3. 21-30%'
            WHEN discount <= 0.5 THEN '4. 31-50%'
            ELSE                      '5. over 50%' END AS discount_band,
       COUNT(*)              AS order_lines,
       ROUND(SUM(net_sales)) AS net_sales,
       ROUND(SUM(profit))    AS profit,
       ROUND(100.0 * SUM(profit) / SUM(net_sales), 1) AS margin_on_net_pct
FROM clean_orders
WHERE is_probable_duplicate = 0
GROUP BY order_year, discount_band
ORDER BY discount_band, order_year;

--
SELECT market,
       order_year,
       ROUND(SUM(gross_sales)) AS gross_sales,
       ROUND(SUM(net_sales))   AS net_sales,
       ROUND(100.0 * SUM(profit) / SUM(net_sales), 1) AS margin_on_net_pct
FROM clean_orders
WHERE is_probable_duplicate = 0
GROUP BY market, order_year
ORDER BY market, order_year;

--
WITH seg AS (
    SELECT segment,
           order_year,
           ROUND(SUM(gross_sales)) AS gross_sales,
           ROUND(SUM(net_sales))   AS net_sales
    FROM clean_orders
    WHERE is_probable_duplicate = 0
    GROUP BY segment, order_year
)
SELECT *,
       ROUND(100.0 * (gross_sales - LAG(gross_sales) OVER (PARTITION BY segment ORDER BY order_year))
             / LAG(gross_sales) OVER (PARTITION BY segment ORDER BY order_year), 1) AS gross_growth_pct,
       ROUND(100.0 * (net_sales - LAG(net_sales) OVER (PARTITION BY segment ORDER BY order_year))
             / LAG(net_sales) OVER (PARTITION BY segment ORDER BY order_year), 1) AS net_growth_pct
FROM seg
ORDER BY segment, order_year;

--
SELECT market,
       ROUND(SUM(CASE WHEN order_year = 2022 THEN profit END)) AS profit_2022,
       ROUND(SUM(CASE WHEN order_year = 2023 THEN profit END)) AS profit_2023,
       ROUND(SUM(CASE WHEN order_year = 2023 THEN profit END)
           - SUM(CASE WHEN order_year = 2022 THEN profit END)) AS profit_change
FROM clean_orders
WHERE is_probable_duplicate = 0
GROUP BY market
ORDER BY profit_change;

--
SELECT order_year,
       COUNT(*)                AS order_lines,
       ROUND(SUM(gross_sales)) AS gross_sales,
       ROUND(SUM(net_sales))   AS net_sales,
       ROUND(SUM(profit))      AS profit
FROM clean_orders
WHERE is_probable_duplicate = 0
  AND discount > 0.3
GROUP BY order_year
ORDER BY order_year;