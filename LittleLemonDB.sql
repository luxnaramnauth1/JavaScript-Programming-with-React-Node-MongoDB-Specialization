-- ============================================================
-- Little Lemon Restaurant - Database Schema & Stored Procedures
-- Capstone Project Deliverable
-- ============================================================

DROP DATABASE IF EXISTS LittleLemonDB;
CREATE DATABASE LittleLemonDB;
USE LittleLemonDB;

-- ============================================================
-- TABLES
-- ============================================================

CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    FullName   VARCHAR(100) NOT NULL,
    Email      VARCHAR(100) NOT NULL,
    Phone      VARCHAR(20)
);

CREATE TABLE Staff (
    StaffID   INT AUTO_INCREMENT PRIMARY KEY,
    FullName  VARCHAR(100) NOT NULL,
    Role      VARCHAR(50),
    Salary    DECIMAL(10,2)
);

CREATE TABLE Bookings (
    BookingID   INT AUTO_INCREMENT PRIMARY KEY,
    BookingDate DATE NOT NULL,
    TableNo     INT NOT NULL,
    CustomerID  INT NOT NULL,
    StaffID     INT,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
);

CREATE TABLE Cuisines (
    CuisineID   INT AUTO_INCREMENT PRIMARY KEY,
    CuisineName VARCHAR(50) NOT NULL
);

CREATE TABLE MenuItems (
    MenuItemID INT AUTO_INCREMENT PRIMARY KEY,
    ItemName   VARCHAR(100) NOT NULL,
    CuisineID  INT,
    Price      DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (CuisineID) REFERENCES Cuisines(CuisineID)
);

CREATE TABLE Menus (
    MenuID     INT AUTO_INCREMENT PRIMARY KEY,
    MenuItemID INT NOT NULL,
    Cuisine    VARCHAR(50),
    FOREIGN KEY (MenuItemID) REFERENCES MenuItems(MenuItemID)
);

CREATE TABLE Orders (
    OrderID     INT AUTO_INCREMENT PRIMARY KEY,
    OrderDate   DATE NOT NULL,
    CustomerID  INT NOT NULL,
    MenuItemID  INT NOT NULL,
    Quantity    INT NOT NULL,
    TotalCost   DECIMAL(10,2),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (MenuItemID) REFERENCES MenuItems(MenuItemID)
);

CREATE TABLE OrderDeliveryStatus (
    DeliveryID    INT AUTO_INCREMENT PRIMARY KEY,
    OrderID       INT NOT NULL,
    DeliveryDate  DATE,
    Status        VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- ============================================================
-- SAMPLE DATA
-- ============================================================

INSERT INTO Customers (FullName, Email, Phone) VALUES
('Vanessa McCarthy', 'vanessa.mc@example.com', '555-0101'),
('Marcos Romero', 'marcos.romero@example.com', '555-0102'),
('Hiroshi Sato', 'hiroshi.sato@example.com', '555-0103'),
('Diana Pinto', 'diana.pinto@example.com', '555-0104');

INSERT INTO Staff (FullName, Role, Salary) VALUES
('Adrian Keller', 'Manager', 4500.00),
('Giulia Romano', 'Head Chef', 3800.00),
('Marco Bianchi', 'Waiter', 2200.00);

INSERT INTO Bookings (BookingDate, TableNo, CustomerID, StaffID) VALUES
('2026-09-20', 5, 1, 3),
('2026-09-20', 2, 2, 3),
('2026-09-21', 7, 3, 1),
('2026-09-22', 3, 4, 3);

INSERT INTO Cuisines (CuisineName) VALUES
('Greek'), ('Italian'), ('Turkish');

INSERT INTO MenuItems (ItemName, CuisineID, Price) VALUES
('Greek salad', 1, 15.00),
('Bean soup', 1, 12.00),
('Pizza', 2, 15.00),
('Carbonara', 2, 15.00),
('Kabasa', 3, 17.00);

INSERT INTO Menus (MenuItemID, Cuisine) VALUES
(1, 'Greek'), (2, 'Greek'), (3, 'Italian'), (4, 'Italian'), (5, 'Turkish');

INSERT INTO Orders (OrderDate, CustomerID, MenuItemID, Quantity, TotalCost) VALUES
('2026-09-15', 1, 1, 2, 30.00),
('2026-09-16', 2, 3, 1, 15.00),
('2026-09-17', 3, 5, 3, 51.00);

INSERT INTO OrderDeliveryStatus (OrderID, DeliveryDate, Status) VALUES
(1, '2026-09-15', 'Delivered'),
(2, '2026-09-16', 'Delivered'),
(3, '2026-09-17', 'Pending');

-- ============================================================
-- STORED PROCEDURES
-- ============================================================

DELIMITER $$

-- 1. GetMaxQuantity: returns the maximum quantity ordered across all orders
DROP PROCEDURE IF EXISTS GetMaxQuantity$$
CREATE PROCEDURE GetMaxQuantity()
BEGIN
    SELECT MAX(Quantity) AS MaxQuantity
    FROM Orders;
END$$

-- 2. ManageBooking: checks whether a table is already booked on a given date
DROP PROCEDURE IF EXISTS ManageBooking$$
CREATE PROCEDURE ManageBooking(IN p_BookingDate DATE, IN p_TableNo INT)
BEGIN
    IF EXISTS (
        SELECT 1 FROM Bookings
        WHERE BookingDate = p_BookingDate AND TableNo = p_TableNo
    ) THEN
        SELECT CONCAT('Table ', p_TableNo, ' is already booked on ', p_BookingDate) AS Status;
    ELSE
        SELECT CONCAT('Table ', p_TableNo, ' is available on ', p_BookingDate) AS Status;
    END IF;
END$$

-- 3. AddBooking: adds a new booking record
DROP PROCEDURE IF EXISTS AddBooking$$
CREATE PROCEDURE AddBooking(
    IN p_BookingID INT,
    IN p_BookingDate DATE,
    IN p_TableNo INT,
    IN p_CustomerID INT,
    IN p_StaffID INT
)
BEGIN
    INSERT INTO Bookings (BookingID, BookingDate, TableNo, CustomerID, StaffID)
    VALUES (p_BookingID, p_BookingDate, p_TableNo, p_CustomerID, p_StaffID);

    SELECT CONCAT('Booking ', p_BookingID, ' added successfully') AS Confirmation;
END$$

-- 4. UpdateBooking: updates the date of an existing booking
DROP PROCEDURE IF EXISTS UpdateBooking$$
CREATE PROCEDURE UpdateBooking(
    IN p_BookingID INT,
    IN p_NewBookingDate DATE
)
BEGIN
    UPDATE Bookings
    SET BookingDate = p_NewBookingDate
    WHERE BookingID = p_BookingID;

    SELECT CONCAT('Booking ', p_BookingID, ' updated to ', p_NewBookingDate) AS Confirmation;
END$$

-- 5. CancelBooking: deletes a booking record
DROP PROCEDURE IF EXISTS CancelBooking$$
CREATE PROCEDURE CancelBooking(IN p_BookingID INT)
BEGIN
    DELETE FROM Bookings WHERE BookingID = p_BookingID;

    SELECT CONCAT('Booking ', p_BookingID, ' has been cancelled') AS Confirmation;
END$$

DELIMITER ;

-- ============================================================
-- EXAMPLE CALLS (for testing — comment out before submission if not needed)
-- ============================================================
-- CALL GetMaxQuantity();
-- CALL ManageBooking('2026-09-20', 5);
-- CALL AddBooking(5, '2026-09-23', 8, 1, 2);
-- CALL UpdateBooking(5, '2026-09-24');
-- CALL CancelBooking(5);
