-- ============================================
-- SQL Quest: Database Schema + Sample Data
-- ============================================
-- Domain: Simple e-commerce store
-- Tables: Customers, Categories, Products, Orders, Order_Items, Payments
-- Run this file first to set up the database before running any queries.
-- ============================================

CREATE DATABASE sql_quest;
USE sql_quest;

-- --------------------------------------------
-- Customers
-- --------------------------------------------
CREATE TABLE Customers(
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    city VARCHAR(50),
    age INT,
    gender VARCHAR(10),
    signup_date DATE
);

INSERT INTO Customers VALUES
(1,'Alice','Mumbai',25,'Female','2023-01-10'),
(2,'Bob','Pune',31,'Male','2023-02-15'),
(3,'Charlie','Delhi',29,'Male','2023-03-20'),
(4,'David','Mumbai',35,'Male','2023-04-22'),
(5,'Emma','Bangalore',27,'Female','2023-05-01'),
(6,'Frank','Pune',40,'Male','2023-06-10'),
(7,'Grace','Delhi',23,'Female','2023-07-14'),
(8,'Henry','Hyderabad',33,'Male','2023-08-08'),
(9,'Isabella','Chennai',26,'Female','2023-09-11'),
(10,'Jack','Mumbai',30,'Male','2023-10-18');

-- --------------------------------------------
-- Categories
-- --------------------------------------------
CREATE TABLE Categories(
    category_id INT PRIMARY KEY,
    category_name VARCHAR(50)
);

INSERT INTO Categories VALUES
(1,'Electronics'),
(2,'Clothing'),
(3,'Furniture'),
(4,'Books'),
(5,'Sports');

-- --------------------------------------------
-- Products
-- --------------------------------------------
CREATE TABLE Products(
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category_id INT,
    price DECIMAL(10,2),
    stock INT,
    FOREIGN KEY(category_id)
    REFERENCES Categories(category_id)
);

INSERT INTO Products VALUES
(101,'Laptop',1,65000,20),
(102,'Phone',1,35000,40),
(103,'Tablet',1,25000,30),
(104,'T-Shirt',2,800,100),
(105,'Jeans',2,1800,60),
(106,'Sofa',3,40000,10),
(107,'Chair',3,5000,25),
(108,'SQL Book',4,900,80),
(109,'Cricket Bat',5,3500,30),
(110,'Football',5,1200,50);

-- --------------------------------------------
-- Orders
-- --------------------------------------------
CREATE TABLE Orders(
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    status VARCHAR(20),
    FOREIGN KEY(customer_id)
    REFERENCES Customers(customer_id)
);

INSERT INTO Orders VALUES
(1001,1,'2024-01-01','Delivered'),
(1002,1,'2024-01-10','Delivered'),
(1003,2,'2024-01-12','Cancelled'),
(1004,3,'2024-02-01','Delivered'),
(1005,4,'2024-02-10','Delivered'),
(1006,4,'2024-02-18','Pending'),
(1007,5,'2024-03-01','Delivered'),
(1008,6,'2024-03-04','Delivered'),
(1009,6,'2024-03-15','Delivered'),
(1010,7,'2024-03-20','Cancelled'),
(1011,8,'2024-04-02','Delivered'),
(1012,9,'2024-04-10','Delivered'),
(1013,10,'2024-04-18','Pending'),
(1014,10,'2024-05-01','Delivered'),
(1015,2,'2024-05-10','Delivered');

-- --------------------------------------------
-- Order_Items
-- --------------------------------------------
CREATE TABLE Order_Items(
    item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY(order_id)
    REFERENCES Orders(order_id),
    FOREIGN KEY(product_id)
    REFERENCES Products(product_id)
);

INSERT INTO Order_Items VALUES
(1,1001,101,1),
(2,1001,108,2),
(3,1002,102,1),
(4,1003,104,4),
(5,1004,103,1),
(6,1005,106,1),
(7,1005,107,4),
(8,1006,109,2),
(9,1007,104,3),
(10,1008,110,2),
(11,1009,101,1),
(12,1010,108,2),
(13,1011,105,2),
(14,1012,102,1),
(15,1013,103,2),
(16,1014,101,1),
(17,1015,109,1),
(18,1015,110,3);

-- --------------------------------------------
-- Payments
-- --------------------------------------------
CREATE TABLE Payments(
    payment_id INT PRIMARY KEY,
    order_id INT,
    payment_method VARCHAR(20),
    amount DECIMAL(10,2),
    payment_date DATE,
    FOREIGN KEY(order_id)
    REFERENCES Orders(order_id)
);

INSERT INTO Payments VALUES
(1,1001,'UPI',66800,'2024-01-01'),
(2,1002,'Card',35000,'2024-01-10'),
(3,1004,'Card',25000,'2024-02-01'),
(4,1005,'NetBanking',60000,'2024-02-10'),
(5,1007,'UPI',2400,'2024-03-01'),
(6,1008,'Cash',2400,'2024-03-04'),
(7,1009,'Card',65000,'2024-03-15'),
(8,1011,'UPI',3600,'2024-04-02'),
(9,1012,'Card',35000,'2024-04-10'),
(10,1014,'UPI',65000,'2024-05-01'),
(11,1015,'Card',7100,'2024-05-10');
