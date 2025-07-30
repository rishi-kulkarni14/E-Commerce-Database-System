DELIMITER //

-- Update Product Stock Status
CREATE TRIGGER trg_update_stock_status
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
    IF NEW.stock_quantity = 0 AND NEW.status != 'discontinued' THEN
        UPDATE products
        SET status = 'inactive'
        WHERE product_id = NEW.product_id;
    END IF;
END //

-- Validate Review Rating
CREATE TRIGGER trg_validate_review
BEFORE INSERT ON product_reviews
FOR EACH ROW
BEGIN
    IF NEW.rating < 1 OR NEW.rating > 5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Rating must be between 1 and 5';
    END IF;
END //

-- Update Order Total
CREATE TRIGGER trg_update_order_total
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE orders
    SET total_amount = (
        SELECT SUM(total_price)
        FROM order_items
        WHERE order_id = NEW.order_id
    )
    WHERE order_id = NEW.order_id;
END //

DELIMITER ;