-- DS5110, Restaurant Project

-- Creating Database and Tables

DROP DATABASE IF EXISTS restaurant;

CREATE DATABASE IF NOT EXISTS restaurant;

use restaurant;

-- User table
CREATE TABLE user (
user_id INT PRIMARY KEY AUTO_INCREMENT, 
user_name VARCHAR(50) UNIQUE NOT NULL, 
password VARCHAR(50) NOT NULL, 
role ENUM("Chef", "Manager", "Customer") NOT NULL);

-- Chef table
CREATE TABLE chef (
chef_id INT PRIMARY KEY,
specialization VARCHAR(50) NOT NULL, 
FOREIGN KEY (chef_id) references user(user_id));

-- Manager table
CREATE TABLE manager (
manager_id INT PRIMARY KEY, 
dept_name VARCHAR(80) NOT NULL,
FOREIGN KEY (manager_id) REFERENCES user(user_id));

-- Customer table
CREATE TABLE customer (
customer_id INT PRIMARY KEY, 
join_date DATETIME DEFAULT NOW(), 
FOREIGN KEY (customer_id) REFERENCES user(user_id));

-- Order table
CREATE TABLE cust_order (
order_id INT PRIMARY KEY AUTO_INCREMENT, 
order_date DATETIME DEFAULT NOW() NOT NULL, 
status ENUM("Received", "Preparing", "Complete") NOT NULL, 
customer_id INT NOT NULL, 
FOREIGN KEY (customer_id) REFERENCES customer(customer_id));

-- Menu items table
CREATE TABLE menu_item (
item_id INT PRIMARY KEY AUTO_INCREMENT,
item_name VARCHAR(20) UNIQUE NOT NULL, 
description VARCHAR(100) UNIQUE NOT NULL, 
price DECIMAL(10,2) NOT NULL, 
category ENUM("Appetizer", "Entree", "Dessert", "Miscellaneous")
);

-- Adjusting datatype restrictions - too short for menu names.
ALTER TABLE menu_item
MODIFY item_name VARCHAR(255);

-- Creating item in order join table
CREATE TABLE item_in_order (
item_id INT, 
order_id INT,
quantity INT(3), 
PRIMARY KEY (item_id, order_id), 
FOREIGN KEY (item_id) REFERENCES menu_item(item_id),
FOREIGN KEY (order_id) REFERENCES cust_order(order_id));

-- Creating a tabel
CREATE TABLE restaurant_table (
table_num INT PRIMARY KEY, 
capacity INT NOT NULL, 
status ENUM("Vacant", "Occupied", "Reserved") NOT NULL);

CREATE TABLE reservation (
res_id INT PRIMARY KEY AUTO_INCREMENT,
date DATE NOT NULL, 
time TIME NOT NULL, 
num_guests INT NOT NULL, 
status ENUM("Reserved", "Cancelled", "No-Show") NOT NULL, 
requests VARCHAR(100), 
table_num INT NOT NULL, 
customer_id INT NOT NULL, 
FOREIGN KEY (table_num) REFERENCES restaurant_table(table_num), 
FOREIGN KEY (customer_id) REFERENCES customer(customer_id));
ALTER TABLE reservation
MODIFY table_num INT;
CREATE TABLE supplier (
supplier_id INT PRIMARY KEY AUTO_INCREMENT,
supplier_name VARCHAR(50) UNIQUE NOT NULL, 
phone_no INT UNIQUE NOT NULL, 
email VARCHAR(50) UNIQUE NOT NULL);

ALTER TABLE supplier
MODIFY phone_no VARCHAR(12);

CREATE TABLE inventory_item (
item_id INT PRIMARY KEY AUTO_INCREMENT,
item_name VARCHAR(50) UNIQUE NOT NULL, 
stock_quantity INT NOT NULL, 
unit_price DECIMAL(10, 2) NOT NULL, 
reorder_threshold INT,
supplier_id INT NOT NULL, 
FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id));

CREATE TABLE weekly_sales (
week_start_date DATE PRIMARY KEY, 
total_sales DECIMAL(10, 2) NOT NULL);


-- Inserting Data

-- Users

INSERT INTO user VALUES 
(1, 'Gordon_Ramsay', 'beefwellington123', 'Chef'), 
(2, 'Rachel_Ray', 'c@ts@nddogs2004!', 'Chef'),
(3, "Olivia_Smith", 'SecurePass1!', "Chef"),
(4, "Ethan_Johnson", 'P@ssw0rd42', "Chef"),
(5, "Ava_Williams", 'Rainbow78@', "Chef"),
(6, "Liam_Jones", 'Secret123$', "Chef"),
(7, "Mia_Brown", 'Purple22%', "Chef"),
(8, "Noah_Davis", 'Sunshine99&', "Chef"),
(9, "Emma_Wilson", 'Sparkle456#', "Chef"),
(10, "Oliver_Miller", 'Moonlight88^', "Chef"),
(11, "Sophia_Taylor", 'OceanWave77*', "Manager"),
(12, "Jackson_Anderson", 'Silver123!', "Manager"),
(13, "Charlotte_Martin", 'StarryNight66$', "Manager"),
(14, "Aiden_Clark", 'GreenApple57@', "Manager"),
(15, "Amelia_Thomas", 'RedRose89#', "Manager"),
(16, "James_White", 'Skyline32^', "Manager"),
(17, "Harper_Harris", 'CoffeeLover75*', "Manager"),
(18, "Benjamin_Lewis", 'MountainView47&', "Manager"),
(19, 'Emily Johnson', 'p@$$word14!', 'Manager'),
(20, 'Michael Brown', 'ItsA$ecret123', 'Manager'),
(21, 'Sarah Brown', 'Purple22@', 'Customer'),
(22, 'David Lee', 'Sunshine99$', 'Customer'), 
(23, 'Jessica Clark', 'Rainbow123!', 'Customer'), 
(24, 'Kevin Wilson', 'Sparkle456#', 'Customer'), 
(25,'Lisa Davis', 'OceanWave77%', 'Customer'), 
(26, 'Robert Anderson', 'Moonlight88@$', 'Customer'),
(27, "Isabella_Jackson", 'SecretPass1!', "Customer"),
(28, "Jacob_Martinez", 'Password123$', "Customer"),
(29, "Sophia_Davis", 'Rainbow45@', "Customer"),
(30, "Michael_Thomas", 'Sunshine67&', "Customer");

-- Chef
INSERT INTO chef VALUES 
(1, 'Italian Cuisine'), 
(2, 'Sushi'),
(3, "Pastry"),
(4, "BBQ"),
(5, "Italian Cuisine"),
(6, "Pastry"),
(7, "French Cuisine"),
(8, "French Cuisine"),
(9, "Fusion"),
(10, "American Cuisine");

-- Manager
INSERT INTO manager VALUES
(11, "Front of House General"),
(12, "Front of House Assistant"),
(13, "Back of House General"),
(14, "Back of House Assistant"),
(15, "Customer Service and Relations General"),
(16, "Customer Service and Relations Assistant"),
(17, "Marketing and Promotion General"),
(18, "Marketing and Promotion Assistant"),
(19, 'Financial Operations General'),
(20, 'Financial Operations Assistant');


-- Customer
INSERT INTO customer(customer_id) VALUES 
(21), (22), (23), (24), (25), (26), (27), (28), (29), (30);

-- Cust_order

INSERT INTO cust_order VALUES 
(101, '2023-09-06 12:00:00', "Complete", 27),
(102, '2023-09-18 08:30:00', "Complete", 22),
(103, '2023-10-05 15:45:00', "Complete", 24),
(104, '2023-10-22 19:20:00', "Complete", 21),
(105, '2023-11-08 14:10:00', "Complete", 25), 
(106, '2023-11-08 10:00:00', "Complete", 21), 
(107, '2023-11-08 21:15:00', "Complete", 27),
(108, '2023-11-08 16:40:00', "Complete", 30),
(109, '2023-11-08 07:55:00', "Complete", 23),
(110, '2023-11-08 11:25:00', "Complete", 22);


-- Menu_item

INSERT INTO menu_item VALUES
(200, 'Caprese Salad', 'Fresh tomatoes, mozzarella, basil, and balsamic glaze', 10.99, 'Appetizer'),
(201, 'Garlic Shrimp', 'Sautéed shrimp in a garlic and herb butter sauce', 14.99, 'Appetizer'),
(202, 'Margherita Pizza', 'Classic pizza with tomatoes, mozzarella, and basil', 12.99, 'Entree'),
(203, 'Chicken Alfredo', 'Fettuccine pasta with creamy Alfredo sauce and grilled chicken', 16.99, 'Entree'),
(204, 'Molten Chocolate Cake', 'Decadent chocolate cake with a molten center', 9.99, 'Dessert'),
(205, 'Tropical Fruit Salad', 'Assorted fresh fruits with a citrus glaze', 7.99, 'Dessert'),
(206, 'Beef Burger', 'Juicy beef patty with lettuce, tomato, and cheese', 13.99, 'Entree'),
(207, 'Miso Soup', 'Traditional Japanese soup with tofu and seaweed', 5.99, 'Appetizer'),
(208, 'Salmon Teriyaki', 'Grilled salmon with teriyaki glaze and steamed vegetables', 18.99, 'Entree'),
(209, 'Cheese Plate', 'Assortment of fine cheeses and crackers', 12.99, 'Appetizer'),
(210, 'Mushroom Risotto', 'Creamy risotto with wild mushrooms and Parmesan', 15.99, 'Entree'),
(211, 'Crème Brûlée', 'Rich custard with a caramelized sugar crust', 8.99, 'Dessert'),
(212, 'Calamari Rings', 'Crispy fried calamari with marinara sauce', 11.99, 'Appetizer'),
(213, 'BBQ Pulled Pork Sandwich', 'Slow-cooked pulled pork with BBQ sauce', 14.99, 'Entree'),
(214, 'Key Lime Pie', 'Tangy key lime pie with graham cracker crust', 6.99, 'Dessert'),
(215, 'Greek Salad', 'Crisp lettuce, feta cheese, olives, and Greek dressing', 9.99, 'Appetizer'),
(216, 'Steak Frites', 'Grilled steak with shoestring fries and béarnaise sauce', 19.99, 'Entree'),
(217, 'Banana Split', 'Classic banana split with ice cream and toppings', 7.99, 'Dessert'),
(218, 'Veggie Spring Rolls', 'Crispy spring rolls with dipping sauce', 10.99, 'Appetizer'),
(219, 'Lobster Ravioli', 'Homemade ravioli with lobster and creamy tomato sauce', 22.99, 'Entree'),
(220, 'Apple Crisp', 'Warm apple crisp with vanilla ice cream', 8.99, 'Dessert'), 
(221, 'Tuna Tartare', 'Fresh tuna, avocado, and sesame soy dressing', 16.99, 'Appetizer'),
(222, 'Lamb Chops', 'Grilled lamb chops with mint sauce', 22.99, 'Entree'),
(223, 'Panna Cotta', 'Italian dessert with caramel and berries', 8.49, 'Dessert'),
(224, 'Spinach Artichoke Dip', 'Creamy dip with spinach and artichokes', 11.99, 'Appetizer'),
(225, 'Shrimp Scampi', 'Sautéed shrimp in a garlic and white wine sauce', 18.99, 'Entree'),
(226, 'Bread Pudding', 'Warm bread pudding with bourbon sauce', 7.99, 'Dessert'),
(227, 'Bruschetta', 'Toasted baguette with tomatoes and basil', 9.99, 'Appetizer'),
(228, 'Vegetable Stir-Fry', 'Assorted vegetables in a savory sauce', 13.99, 'Entree'),
(229, 'Tiramisu', 'Classic Italian dessert with coffee and mascarpone', 8.99, 'Dessert'),
(230, 'Crab Cakes', 'Pan-seared crab cakes with remoulade sauce', 15.99, 'Appetizer'),
(231, 'Beef Stroganoff', 'Tender beef in a creamy mushroom sauce', 17.99, 'Entree'),
(232, 'Chocolate Mousse', 'Silky chocolate mousse with whipped cream', 6.99, 'Dessert'),
(233, 'Vegetable Spring Rolls', 'Crispy spring rolls with sweet chili sauce', 10.99, 'Appetizer'),
(234, 'Ratatouille', 'Provencal vegetable stew with herbs and olive oil', 14.99, 'Entree'),
(235, 'Peach Cobbler', 'Warm peach cobbler with a scoop of vanilla ice cream', 7.99, 'Dessert'),
(236, 'Ceviche', 'Fresh fish and citrus marinade with red onions and cilantro', 12.99, 'Appetizer'),
(237, 'Chicken Piccata', 'Pan-seared chicken with lemon caper sauce', 19.99, 'Entree'),
(238, 'Banana Cream Pie', 'Banana cream pie with whipped cream topping', 8.99, 'Dessert'),
(239, 'Hummus Platter', 'Creamy hummus with pita bread and veggies', 9.99, 'Appetizer'),
(240, 'Vegetarian Lasagna', 'Layered pasta with vegetables and cheese', 16.99, 'Entree');

-- item_in_order

INSERT INTO item_in_order VALUES
-- Order 101
(200, 101, 2),   -- Caprese Salad
(202, 101, 3),   -- Margherita Pizza
(215, 101, 1),   -- Greek Salad
-- Order 102
(203, 102, 2),   -- Chicken Alfredo
(208, 102, 2),   -- Salmon Teriyaki
-- Order 103
(221, 103, 1),   -- Tuna Tartare
(231, 103, 2),   -- Beef Stroganoff
(205, 103, 1),   -- Tropical Fruit Salad
(211, 103, 3),   -- Crème Brûlée
-- Order 104
(210, 104, 3),   -- Mushroom Risotto
(214, 104, 2),   -- Key Lime Pie
-- Order 105
(212, 105, 2),   -- Calamari Rings
(216, 105, 1),   -- Steak Frites
-- Order 106
(213, 106, 1),   -- BBQ Pulled Pork Sandwich
-- Order 107
(222, 107, 2),   -- Lamb Chops
(225, 107, 1),   -- Shrimp Scampi
(237, 107, 1),   -- Chicken Piccata
(218, 107, 2),   -- Banana Split
(223, 107, 1),   -- Panna Cotta
-- Order 108
(224, 108, 2),   -- Spinach Artichoke Dip
(228, 108, 3),   -- Vegetable Stir-Fry
(235, 108, 1),   -- Peach Cobbler
-- Order 109
(233, 109, 1),   -- Vegetable Spring Rolls
(237, 109, 2),   -- Chicken Piccata
-- Order 110
(229, 110, 3);   -- Cheese Plate


-- restaurant_table

 INSERT INTO restaurant_table VALUES
(1, 2, 'Vacant'),
(2, 4, 'Vacant'),
(3, 6, 'Vacant'),
(4, 3, 'Vacant'),
(5, 5, 'Vacant'),
(6, 7, 'Vacant'),
(7, 8, 'Vacant'),
(8, 2, 'Vacant'),
(9, 4, 'Vacant'),
(10, 6, 'Vacant'),
(11, 3, 'Vacant'),
(12, 5, 'Vacant'),
(13, 7, 'Vacant'),
(14, 8, 'Vacant'),
(15, 2, 'Vacant'),
(16, 4, 'Vacant'),
(17, 6, 'Vacant'),
(18, 3, 'Vacant'),
(19, 5, 'Vacant'),
(20, 7, 'Vacant'),
(21, 8, 'Vacant'),
(22, 2, 'Vacant'),
(23, 4, 'Vacant'),
(24, 6, 'Vacant');

-- reservation
-- CREATE TABLE reservation (
-- res_id INT PRIMARY KEY AUTO_INCREMENT,
-- date DATE NOT NULL, 
-- time TIME NOT NULL, 
-- num_guests INT NOT NULL, 
-- status ENUM("Reserved", "Cancelled", "No-Show") NOT NULL, 
-- requests VARCHAR(100), 
-- table_num INT NOT NULL, 
-- customer_id INT NOT NULL, 
-- FOREIGN KEY (table_num) REFERENCES restaurant_table(table_num), 
-- FOREIGN KEY (customer_id) REFERENCES customer(customer_id));

-- Insert reservation records
INSERT INTO reservation (date, time, num_guests, status, requests, table_num, customer_id) VALUES
('2023-11-15', '18:30:00', 6, 'Reserved', 'Window seat', 3, 21),
('2023-11-20', '20:15:00', 5, 'Reserved', 'Birthday celebration', 12, 23),
('2023-11-22', '17:45:00', 6, 'Reserved', 'Quiet corner', 17, 24),
('2023-11-28', '19:30:00', 7, 'Reserved', 'Business meeting', 6, 26),
('2023-12-12', '21:00:00', 5, 'Reserved', 'Surprise party', 24, 30),
('2023-12-15', '18:30:00', 4, 'Reserved', 'Window seat', 3, 21),
('2023-12-24', '17:45:00', 4, 'Reserved', 'Quiet corner', 2, 24),
('2023-12-30', '19:30:00', 7, 'Reserved', 'Business meeting', 6, 24);

INSERT INTO reservation (date, time, num_guests, status, table_num, customer_id) VALUES
('2023-11-17', '19:00:00', 2, 'Reserved', 8, 22),
('2023-11-25', '18:00:00', 2, 'Reserved', 1, 25),
('2023-12-01', '20:00:00', 3, 'Reserved', 11, 27),
('2023-12-05', '18:45:00', 6, 'Reserved', 20, 28),
('2023-12-08', '19:15:00', 3, 'Reserved', 4, 29),
('2023-12-18', '19:00:00', 2, 'Reserved', 8, 22),
('2023-12-21', '20:15:00', 3, 'Reserved', 12, 23),
('2023-12-27', '18:00:00', 2, 'Reserved', 22, 22),
('2024-01-03', '20:00:00', 2, 'Reserved', 15, 27);

-- supplier

INSERT INTO supplier VALUES
(1, 'Gourmet Food Distributors', '123-456-7890', 'gourmetfoods@example.com'),
(2, 'Culinary Essentials Co.', '987-654-3210', 'culinaryessentials@mail.com'),
(3, 'Fresh Produce Supply', '555-333-7777', 'freshproduce@mail.com'),
(4, 'Kitchenware Innovations', '111-222-3333', 'kitcheninnovations@example.com'),
(5, 'Quality Ingredients Ltd.', '999-888-7777', 'qualityingredients@mail.com'),
(6, 'Restaurant Equipment Solutions', '444-555-6666', 'restequip@mail.com'),
(7, 'Bakery Supplies Ltd.', '777-222-1111', 'bakerysupplies@mail.com'),
(8, 'Tableware Creations Inc.', '666-999-8888', 'tableware@example.com'),
(9, 'Chefs Pantry Corp.', '222-444-6666', 'chefspantry@mail.com'),
(10, 'Beverage Solutions Unlimited', '888-777-5555', 'beveragesolutions@mail.com');

-- inventory_item
 
INSERT INTO inventory_item (item_name, stock_quantity, unit_price, reorder_threshold, supplier_id) VALUES
('Fresh Tomatoes', 500, 1.99, 100, 1),
('Premium Olive Oil', 200, 7.99, 50, 2),
('Prime Beef Cuts', 300, 12.99, 75, 3),
('Organic Greens Mix', 400, 5.99, 80, 4),
('High-Quality Salmon Fillets', 150, 9.99, 30, 5),
('Artisan Cheeses Assortment', 250, 8.99, 60, 6),
('Specialty Coffee Beans', 100, 14.99, 20, 7),
('Fresh Baking Flour', 600, 3.49, 150, 8),
('Exquisite Wine Selection', 120, 19.99, 25, 9),
('Premium Dessert Chocolate', 180, 6.99, 40, 10),
('Aged Balsamic Vinegar', 300, 10.99, 70, 1),
('Top-Quality Pasta Varieties', 250, 4.99, 60, 2),
('Deluxe Cooking Utensil Set', 80, 29.99, 15, 3),
('Gourmet Spice Collection', 150, 8.49, 35, 4),
('Artificial Sweeteners Pack', 400, 2.99, 100, 5),
('Culinary Herbs Assortment', 200, 6.49, 50, 6),
('Premium Cooking Oils Bundle', 180, 11.99, 40, 7),
('Specialty Seafood Seasonings', 120, 4.79, 30, 8),
('Exclusive Chefs Knife Set', 100, 49.99, 20, 9),
('Fine Wine Glasses Set', 50, 12.99, 10, 10);

-- weekly_sales

INSERT INTO weekly_sales VALUES
('2023-10-30', 15000.25),
('2023-10-23', 12000.75),
('2023-10-16', 13500.50),
('2023-10-09', 11000.80),
('2023-10-02', 10000.40),
('2023-09-25', 9500.60),
('2023-09-18', 12200.30),
('2023-09-11', 11500.90),
('2023-09-04', 10500.20),
('2023-08-28', 13000.45),
('2023-08-21', 14000.70),
('2023-08-14', 11800.55),
('2023-08-07', 12500.35),
('2023-07-31', 13200.65),
('2023-07-24', 9800.85),
('2023-07-17', 10700.95),
('2023-07-10', 12600.10),
('2023-07-03', 11600.40),
('2023-06-26', 14200.20),
('2023-06-19', 15500.15);


-- -------------------------- Stored Procedures -------------------------- --

DELIMITER //
CREATE PROCEDURE GetUserOrders(IN userId INT)
BEGIN
    -- Show past orders
    SELECT
        co.order_id,
        co.order_date,
        mi.item_name,
        io.quantity,
        co.status
    FROM
        cust_order co
    JOIN
        item_in_order io ON co.order_id = io.order_id
    JOIN
        menu_item mi ON io.item_id = mi.item_id
    WHERE
        co.customer_id = userId
        AND co.status = 'Complete'
    ORDER BY
        co.order_date DESC;

    -- Show present orders
    SELECT
        co.order_id,
        co.order_date,
        mi.item_name,
        io.quantity,
        co.status
    FROM
        cust_order co
    JOIN
        item_in_order io ON co.order_id = io.order_id
    JOIN
        menu_item mi ON io.item_id = mi.item_id
    WHERE
        co.customer_id = userId
        AND co.status != 'Complete'
    ORDER BY
        co.order_date DESC;
END //  DELIMITER ;

DROP PROCEDURE AddUserWithRole;
-- SP: adding a user with different permisions based on their role
DELIMITER //
CREATE PROCEDURE AddUserWithRole(IN user_name VARCHAR(50), IN user_password VARCHAR(50), IN role ENUM("Chef", "Manager", "Customer"))
SQL SECURITY DEFINER
BEGIN
   -- Insert the new user into the user table
   INSERT INTO user(user_name, password, role) VALUES(user_name, user_password, role);
   
   -- Creating user
   SET @create_user_query = CONCAT('CREATE USER ', user_name, '@localhost IDENTIFIED BY ', "'", user_password, "'");
   PREPARE create_user_stmt FROM @create_user_query;
   EXECUTE create_user_stmt;
   DEALLOCATE PREPARE create_user_stmt;
	
END//
DELIMITER ;
select * from user where role = 'Chef';




-- ----------------------------- Functions ----------------------------- --
use restaurant;
select * from reservation;
-- Calculate number of people reserved per night
SET GLOBAL log_bin_trust_function_creators = 1;
DROP FUNCTION IF EXISTS num_reserved;
DELIMITER $$
CREATE FUNCTION num_reserved (
input_date DATE)
RETURNS INT
BEGIN
DECLARE total_reserved INT;

SELECT IFNULL(sum(num_guests),0) INTO total_reserved
FROM reservation
WHERE date = input_date AND status = 'reserved';

RETURN total_reserved;

END $$
DELIMITER ;

select * from weekly_sales;

-- function: calculate difference between current inventory and reorder threshold
DELIMITER //
CREATE FUNCTION CalculateInventoryDifference(itemId INT)
RETURNS INT
BEGIN
    DECLARE currentInventory INT;
    DECLARE reorderThreshold INT;
    DECLARE difference INT;

    -- Get current inventory and reorder threshold for the specified item
    SELECT stock_quantity, reorder_threshold
    INTO currentInventory, reorderThreshold
    FROM inventory_item
    WHERE item_id = itemId;

    -- Calculate the difference
    SET difference = currentInventory - reorderThreshold;

    -- Return the difference
    RETURN difference;
END //
DELIMITER ;


DELIMITER //
CREATE FUNCTION get_order_total(
input_order_id INT) RETURNS DECIMAL(10,2)
BEGIN
DECLARE total DECIMAL(10, 2);

SELECT sum(mi.price * i_o.quantity)
INTO total
FROM item_in_order i_o
JOIN menu_item mi ON i_o.item_id = mi.item_id
WHERE io.order_id = input_order_id;

RETURN COALESCE(total, 0.00);
END;
DELIMITER ;
-- ----------------------------- Triggers ----------------------------- --

-- After update on order table, add order total to weekly_sales
DROP TRIGGER IF EXISTS update_weekly_sales;
DELIMITER $$
CREATE TRIGGER update_weekly_sales AFTER UPDATE on cust_order
FOR EACH ROW
BEGIN
DECLARE order_total DECIMAL(10, 2);
DECLARE current_week DATE;
DECLARE week_start DATE;
DECLARE days_apart INT;

SET order_total = get_order_total(NEW.order_id);
SELECT week_start_date
FROM weekly_sales
ORDER BY week_start_date DESC
LIMIT 1
INTO current_week;
SET week_start = DATE_SUB(NEW.order_date, INTERVAL WEEKDAY(NEW.order_date) DAY);
SET days_apart = DATEDIFF(NEW.order_date, current_week);

IF days_apart < 7
THEN
UPDATE weekly_sales
SET total_sales = total_sales + order_total
WHERE week_start_date = week_start;
ELSE 
INSERT INTO weekly_sales
VALUES (week_start, order_total);
END IF; 

END $$
DELIMITER ;


-- ------------------------------ Views ------------------------------ --
CREATE VIEW CustomerView AS
SELECT
    r.res_id,
    r.date AS reservation_date,
    r.time AS reservation_time,
    r.num_guests,
    r.status AS reservation_status,
    r.requests AS special_requests,
    rt.table_num,
    mi.item_id,
    mi.item_name,
    mi.description,
    mi.price,
    mi.category
FROM
    reservation r
LEFT JOIN
    restaurant_table rt ON r.table_num = rt.table_num
LEFT JOIN
    cust_order co ON r.customer_id = co.customer_id
LEFT JOIN
    item_in_order io ON co.order_id = io.order_id
LEFT JOIN
    menu_item mi ON io.item_id = mi.item_id;

-- VIEW: Chef View: includes ONLY information about inventory and order details
CREATE VIEW ChefView AS
SELECT item_name, stock_quantity, reorder_threshold
FROM inventory_item;
SELECT * FROM ChefView;

-- Creating existing user profiles - used for testing application

-- Remote DBA - access to every table in the restaurant database as well as grant optins
-- and procedure execution privileges
CREATE user 'test'@'localhost' IDENTIFIED BY 'my_password';
GRANT SELECT, INSERT, UPDATE , DELETE ON restaurant.* TO 'test'@'localhost';
GRANT EXECUTE ON PROCEDURE restaurant.AddUserWithRole TO 'test'@'localhost';
GRANT GRANT OPTION ON restaurant.* TO 'test'@'localhost';

-- Sample Chef Profile
CREATE USER 'Gordon_Ramsay'@'localhost' IDENTIFIED BY 'beefwellington123';
GRANT SELECT on restaurant.user TO 'Gordon_Ramsay'@'localhost';
GRANT SELECT, INSERT, UPDATE ON restaurant.inventory_item TO 'Gordon_Ramsay'@'localhost';
GRANT SELECT, INSERT, UPDATE ON restaurant.cust_order TO 'Gordon_Ramsay'@'localhost';

-- Sample Manager Profile
CREATE USER 'Sophia_Taylor'@'localhost' IDENTIFIED BY 'OceanWave77*';
GRANT SELECT, INSERT, UPDATE on restaurant.* TO 'Sophia_Taylor'@'localhost';

-- Sample Customer Profile
CREATE USER 'Michael_Thomas'@'localhost' IDENTIFIED BY 'Sunshine67&';
GRANT SELECT ON restaurant.user TO 'Michael_Thomas'@'localhost';
GRANT SELECT, INSERT, UPDATE on restaurant.reservation to 'Michael_Thomas'@'localhost';
GRANT DELETE on restaurant.reservation to 'Michael_Thomas'@'localhost';
GRANT SELECT ON restaurant.menu_item TO 'Michael_Thomas'@'localhost';
GRANT SELECT, INSERT, UPDATE on restaurant.cust_order TO 'Michael_Thomas'@'localhost';
GRANT SELECT, INSERT, UPDATE on restaurant.item_in_order TO 'Michael_Thomas'@'localhost';