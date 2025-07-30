-- Product Analytics View
CREATE VIEW vw_product_analytics AS
SELECT 
    p.product_id,
    p.name,
    p.price,
    p.stock_quantity,
    COUNT(DISTINCT oi.order_id) as total_orders,
    SUM(oi.quantity) as total_units_sold,
    AVG(pr.rating) as avg_rating,
    COUNT(pr.review_id) as review_count
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN product_reviews pr ON p.product_id = pr.product_id
GROUP BY p.product_id;

-- Customer Order History View
CREATE VIEW vw_customer_order_history AS
SELECT 
    u.user_id,
    u.email,
    COUNT(o.order_id) as total_orders,
    SUM(o.total_amount) as total_spent,
    MAX(o.created_at) as last_order_date,
    AVG(o.total_amount) as avg_order_value
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
GROUP BY u.user_id;

-- Category Performance View
CREATE VIEW vw_category_performance AS
SELECT 
    c.category_id,
    c.name as category_name,
    COUNT(DISTINCT p.product_id) as total_products,
    SUM(oi.quantity) as total_units_sold,
    SUM(oi.total_price) as total_revenue,
    AVG(pr.rating) as avg_category_rating
FROM categories c
LEFT JOIN products p ON c.category_id = p.category_id
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN product_reviews pr ON p.product_id = pr.product_id
GROUP BY c.category_id;