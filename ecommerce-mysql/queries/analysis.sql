-- Best Selling Products
SELECT 
    p.name,
    p.price,
    SUM(oi.quantity) as total_sold,
    SUM(oi.quantity * oi.price_per_unit) as total_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id
ORDER BY total_revenue DESC
LIMIT 10;

-- Customer Segmentation
SELECT 
    CASE 
        WHEN total_spent >= 1000 THEN 'Premium'
        WHEN total_spent >= 500 THEN 'Gold'
        ELSE 'Regular'
    END as customer_segment,
    COUNT(*) as customer_count,
    AVG(total_spent) as avg_spent,
    MIN(total_spent) as min_spent,
    MAX(total_spent) as max_spent
FROM vw_customer_order_history
GROUP BY 
    CASE 
        WHEN total_spent >= 1000 THEN 'Premium'
        WHEN total_spent >= 500 THEN 'Gold'
        ELSE 'Regular'
    END;

-- Product Performance Analysis
SELECT 
    p.name,
    p.price,
    p.stock_quantity,
    COUNT(pr.review_id) as review_count,
    AVG(pr.rating) as avg_rating,
    COUNT(DISTINCT oi.order_id) as order_count,
    SUM(oi.quantity) as units_sold,
    SUM(oi.quantity * oi.price_per_unit) as total_revenue,
    CASE 
        WHEN p.stock_quantity = 0 THEN 'Out of Stock'
        WHEN p.stock_quantity < 10 THEN 'Low Stock'
        ELSE 'In Stock'
    END as stock_status
FROM products p
LEFT JOIN product_reviews pr ON p.product_id = pr.product_id
LEFT JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id
ORDER BY total_revenue DESC;

-- Category Revenue Analysis
SELECT 
    c.name as category_name,
    COUNT(DISTINCT p.product_id) as product_count,
    COUNT(DISTINCT o.order_id) as order_count,
    SUM(oi.quantity) as total_units_sold,
    SUM(oi.quantity * oi.price_per_unit) as total_revenue,
    AVG(pr.rating) as avg_category_rating
FROM categories c
LEFT JOIN products p ON c.category_id = p.category_id
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id
LEFT JOIN product_reviews pr ON p.product_id = pr.product_id
GROUP BY c.category_id
ORDER BY total_revenue DESC;

-- Monthly Sales Trend
SELECT 
    DATE_FORMAT(o.created_at, '%Y-%m') as month,
    COUNT(DISTINCT o.order_id) as total_orders,
    COUNT(DISTINCT o.user_id) as unique_customers,
    SUM(o.total_amount) as total_revenue,
    AVG(o.total_amount) as avg_order_value
FROM orders o
WHERE o.order_status != 'cancelled'
GROUP BY DATE_FORMAT(o.created_at, '%Y-%m')
ORDER BY month DESC;

-- Customer Purchase Frequency
SELECT 
    user_id,
    COUNT(*) as total_orders,
    MIN(created_at) as first_order_date,
    MAX(created_at) as last_order_date,
    DATEDIFF(MAX(created_at), MIN(created_at)) as days_between_first_last_order,
    SUM(total_amount) as total_spent,
    AVG(total_amount) as avg_order_value
FROM orders
WHERE order_status != 'cancelled'
GROUP BY user_id
HAVING total_orders > 1
ORDER BY total_orders DESC;

-- Product Return Rate Analysis
SELECT 
    p.name as product_name,
    COUNT(DISTINCT o.order_id) as total_orders,
    COUNT(DISTINCT CASE WHEN o.order_status = 'returned' THEN o.order_id END) as returned_orders,
    (COUNT(DISTINCT CASE WHEN o.order_status = 'returned' THEN o.order_id END) / COUNT(DISTINCT o.order_id) * 100) as return_rate
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
GROUP BY p.product_id
HAVING total_orders >= 10
ORDER BY return_rate DESC;

-- Customer Retention Analysis
WITH customer_orders AS (
    SELECT 
        user_id,
        DATE_FORMAT(created_at, '%Y-%m') as order_month,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at) as order_number
    FROM orders
    WHERE order_status != 'cancelled'
)
SELECT 
    first_orders.order_month as cohort_month,
    COUNT(DISTINCT first_orders.user_id) as cohort_size,
    COUNT(DISTINCT repeat_orders.user_id) as returning_customers,
    (COUNT(DISTINCT repeat_orders.user_id) / COUNT(DISTINCT first_orders.user_id) * 100) as retention_rate
FROM customer_orders first_orders
LEFT JOIN customer_orders repeat_orders 
    ON first_orders.user_id = repeat_orders.user_id
    AND first_orders.order_number = 1
    AND repeat_orders.order_number = 2
WHERE first_orders.order_number = 1
GROUP BY first_orders.order_month
ORDER BY first_orders.order_month;

-- High-Value Products Analysis
SELECT 
    p.name,
    p.price,
    COUNT(DISTINCT o.order_id) as order_count,
    SUM(oi.quantity) as units_sold,
    SUM(oi.quantity * oi.price_per_unit) as total_revenue,
    AVG(pr.rating) as avg_rating
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id
LEFT JOIN product_reviews pr ON p.product_id = pr.product_id
WHERE p.price >= (SELECT AVG(price) * 2 FROM products)
GROUP BY p.product_id
ORDER BY total_revenue DESC;

-- Customer Shopping Pattern Analysis
SELECT 
    HOUR(created_at) as hour_of_day,
    COUNT(*) as total_orders,
    AVG(total_amount) as avg_order_value,
    CASE 
        WHEN WEEKDAY(created_at) < 5 THEN 'Weekday'
        ELSE 'Weekend'
    END as day_type
FROM orders
WHERE order_status != 'cancelled'
GROUP BY 
    HOUR(created_at),
    CASE 
        WHEN WEEKDAY(created_at) < 5 THEN 'Weekday'
        ELSE 'Weekend'
    END
ORDER BY hour_of_day;