--5.1 Correlated Scalar Subquery in WHERE

SELECT 
    p1.product_id,
    p1.product_name,
    p1.brand_id,
    p1.list_price
FROM production.products p1
WHERE p1.list_price > (
    SELECT AVG(p2.list_price)
    FROM production.products p2
    WHERE p2.brand_id = p1.brand_id
);


--5.2 Orders Placed by Customers in NY or CA Using IN


SELECT 
    order_id,
    customer_id,
    order_status,
    order_date
FROM sales.orders
WHERE customer_id IN (
    SELECT customer_id
    FROM sales.customers
    WHERE state IN ('NY', 'CA')
);

--5.3 Fixing the NOT IN NULL Trap
--If the subquery returns even a single NULL, the entire NOT IN predicate evaluates to UNKNOWN (effectively FALSE), returning zero rows.


SELECT customer_id 
FROM sales.customers
WHERE customer_id NOT IN (
    SELECT customer_id 
    FROM sales.orders 
    WHERE customer_id IS NOT NULL
);


--5.4 Average Number of Items per Order via Derived Table

SELECT 
    ROUND(AVG(item_count * 1.0), 2) AS avg_items_per_order
FROM (
    SELECT 
        order_id,
        SUM(quantity) AS item_count
    FROM sales.order_items
    GROUP BY order_id
) AS order_item_totals;


--5.5 Rewriting EXISTS to IN & Safety Comparison
--Standard EXISTS Pattern:

SELECT c.customer_id, c.first_name, c.last_name
FROM sales.customers c
WHERE EXISTS (
    SELECT 1 
    FROM sales.orders o 
    WHERE o.customer_id = c.customer_id
);


--5.6 Top 3 Most Recent Orders per Customer Using CROSS APPLY

SELECT 
    c.customer_id,
    c.first_name,
    recent_orders.order_id,
    recent_orders.order_date
FROM sales.customers c
CROSS APPLY (
    SELECT TOP 3 
        o.order_id,
        o.order_date
    FROM sales.orders o
    WHERE o.customer_id = c.customer_id
    ORDER BY o.order_date DESC, o.order_id DESC
) AS recent_orders;


--5.7 Conceptual Analysis: ANY vs. IN vs. ALL

SELECT product_name, list_price
FROM production.products
WHERE category_id = 1
  AND list_price > ALL (
      SELECT list_price 
      FROM production.products 
      WHERE category_id = 2
  );