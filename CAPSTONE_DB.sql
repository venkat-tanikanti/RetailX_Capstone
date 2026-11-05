CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100) ,
    email VARCHAR(100),
    phone NUMERIC,
    age NUMERIC CHECK (age >= 0),
    gender VARCHAR(20),
    city VARCHAR(20),
    state VARCHAR(20),
    registration_date DATE ,
    loyalty_tier VARCHAR(20) ,
    is_active VARCHAR(10)
);
SELECT * FROM customers

CREATE TABLE marketing (
    campaign_id VARCHAR(20) PRIMARY KEY,
    campaign_name VARCHAR(30) ,
    channel VARCHAR(30),
    start_date DATE ,
    duration_days NUMERIC,
    spend_inr NUMERIC,
    impressions NUMERIC ,
    clicks NUMERIC,
    conversions NUMERIC ,
    revenue_generated NUMERIC,
    ab_group VARCHAR(20),
    target_segment VARCHAR(20)   
);
SELECT * FROM public.marketing

CREATE TABLE orders (
    order_id VARCHAR(30) PRIMARY KEY,
    customer_id VARCHAR(20) REFERENCES customers(customer_id) ON DELETE CASCADE,
    product_id VARCHAR(20), 
    order_date DATE ,
    quantity NUMERIC,
    unit_price NUMERIC,
    discount_pct NUMERIC,
    discount_amount NUMERIC(10, 2),    
    total_amount NUMERIC(12, 2),    
    payment_method VARCHAR(20),
    order_status VARCHAR(20),
    delivery_days NUMERIC,
    region VARCHAR(10)
);
SELECT * FROM orders

CREATE TABLE products (
    product_id VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(30),
    category VARCHAR(30),
    cost_price NUMERIC,
    selling_price NUMERIC,    
    margin_pct NUMERIC(5, 2),    
    stock_qty NUMERIC,
    supplier VARCHAR(50),
    rating NUMERIC(3, 2)
);
SELECT * FROM products

CREATE TABLE returns (
    return_id VARCHAR(30) PRIMARY KEY,    
    order_id VARCHAR(30) UNIQUE REFERENCES orders(order_id) ON DELETE CASCADE,    
    return_date DATE,
    return_reason VARCHAR(50),
    refund_amount NUMERIC(12, 2),    
    refund_status VARCHAR(20)
);
SELECT * FROM returns