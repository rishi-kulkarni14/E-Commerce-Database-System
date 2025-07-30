# E-commerce Database System

A comprehensive MySQL database solution designed for e-commerce platforms. This project implements a complete database structure with user management, product cataloging, shopping cart functionality, order processing, and advanced analytics capabilities.

## 🌟 Features

### Core Functionality
- User Account Management
- Product Catalog & Inventory
- Shopping Cart System
- Order Processing & Tracking
- Customer Reviews & Ratings
- Address Management
- Category Management

## 📋 Database Structure

### Main Tables
1. `users` - Customer information and accounts
2. `products` - Product catalog and inventory
3. `categories` - Product categorization
4. `orders` - Order tracking and management
5. `order_items` - Individual items in orders
6. `cart` - Shopping cart functionality
7. `addresses` - Customer shipping addresses
8. `product_reviews` - Customer reviews and ratings

### Views
- `vw_product_analytics` - Product performance metrics
- `vw_customer_order_history` - Customer purchase history
- `vw_category_performance` - Category-wise analysis

## 🚀 Installation

### Prerequisites
- MySQL Server 8.0 or higher
- MySQL Workbench (recommended) or command-line interface

### Step-by-Step Installation

1. Clone the repository
```bash
git clone https://github.com/nirantbendale/ecommerce-mysql.git
cd ecommerce-mysql
```

2. Create the database
```sql
CREATE DATABASE ecommerce;
USE ecommerce;
```

3. Import database structure (in this order)
```bash
# Create tables
mysql -u root -p ecommerce < database/tables/init.sql

# Create stored procedures
mysql -u root -p ecommerce < database/procedures/procedures.sql

# Create triggers
mysql -u root -p ecommerce < database/triggers/triggers.sql

# Create views
mysql -u root -p ecommerce < database/views/views.sql

# Import sample data (optional)
mysql -u root -p ecommerce < sample_data/sample_data.sql
```

## 💻 Usage Examples

### Adding Products to Cart
```sql
-- Add item to cart (user_id, product_id, quantity)
CALL sp_add_to_cart(1, 1, 2);

-- View cart contents
SELECT c.*, p.name, p.price 
FROM cart c 
JOIN products p ON c.product_id = p.product_id 
WHERE c.user_id = 1;
```

### Processing Orders
```sql
-- Place order (user_id, address_id)
CALL sp_place_order(1, 1);

-- View order details
SELECT * FROM orders WHERE user_id = 1;
```

### Running Analytics
```sql
-- View product performance
SELECT * FROM vw_product_analytics;

-- View customer history
SELECT * FROM vw_customer_order_history;
```

## 📊 Sample Queries

### Best Selling Products
```sql
SELECT 
    p.name,
    SUM(oi.quantity) as total_sold,
    SUM(oi.quantity * oi.price_per_unit) as total_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id
ORDER BY total_revenue DESC
LIMIT 10;
```

### Customer Segmentation
```sql
SELECT 
    CASE 
        WHEN total_spent >= 1000 THEN 'Premium'
        WHEN total_spent >= 500 THEN 'Gold'
        ELSE 'Regular'
    END as customer_segment,
    COUNT(*) as customer_count,
    AVG(total_spent) as avg_spent
FROM vw_customer_order_history
GROUP BY 1;
```

## 📁 Project Structure
```
ecommerce-mysql/
├── database/
│   ├── tables/
│   │   └── init.sql
│   ├── procedures/
│   │   └── procedures.sql
│   ├── triggers/
│   │   └── triggers.sql
│   └── views/
│       └── views.sql
├── sample_data/
│   └── sample_data.sql
├── queries/
│   └── analysis.sql
├── .gitignore
└── README.md
```

## 🛠️ Technical Details

### Stored Procedures
- `sp_add_to_cart` - Manages cart operations
- `sp_place_order` - Processes orders
- `sp_update_order_status` - Updates order status
- `sp_add_product_review` - Handles product reviews

### Triggers
- Stock level monitoring
- Order status updates
- Review validation

### Performance Optimization
- Proper indexing on frequently queried columns
- Optimized table relationships
- Efficient query design


---
Created by Nirant Bendale - Feel free to contact me!
