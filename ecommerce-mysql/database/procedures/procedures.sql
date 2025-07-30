DELIMITER //

-- Add Product to Cart
CREATE PROCEDURE sp_add_to_cart(
    IN p_user_id INT,
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_stock INT;
    DECLARE v_existing_qty INT;
    
    -- Check product stock
    SELECT stock_quantity INTO v_stock
    FROM products
    WHERE product_id = p_product_id;
    
    IF v_stock >= p_quantity THEN
        -- Check if product already in cart
        SELECT quantity INTO v_existing_qty
        FROM cart
        WHERE user_id = p_user_id AND product_id = p_product_id;
        
        IF v_existing_qty IS NULL THEN
            INSERT INTO cart (user_id, product_id, quantity)
            VALUES (p_user_id, p_product_id, p_quantity);
        ELSE
            UPDATE cart
            SET quantity = v_existing_qty + p_quantity
            WHERE user_id = p_user_id AND product_id = p_product_id;
        END IF;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient stock';
    END IF;
END //

-- Place Order
CREATE PROCEDURE sp_place_order(
    IN p_user_id INT,
    IN p_address_id INT
)
BEGIN
    DECLARE v_total DECIMAL(10,2) DEFAULT 0;
    DECLARE v_order_id INT;
    
    START TRANSACTION;
    
    -- Calculate total from cart
    SELECT SUM(c.quantity * p.price) INTO v_total
    FROM cart c
    JOIN products p ON c.product_id = p.product_id
    WHERE c.user_id = p_user_id;
    
    -- Create order
    INSERT INTO orders (user_id, address_id, total_amount)
    VALUES (p_user_id, p_address_id, v_total);
    
    SET v_order_id = LAST_INSERT_ID();
    
    -- Transf