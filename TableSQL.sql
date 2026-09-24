CREATE TABLE orders(
OrderID VARCHAR(20),
OrderDate DATE,
CustomerID VARCHAR(30),
ProductID VARCHAR(20),
Quantity INTEGER,
CustomerName VARCHAR(100),
Email VARCHAR(100),
Country VARCHAR(20),
CoffeeType VARCHAR(20),
RoastType VARCHAR(20),
Size DECIMAL,
UnitPrice DECIMAL(10,2),
Sales DECIMAL(10,2),
CoffeeTypeName VARCHAR(20),
RoastTypeName VARCHAR(20)
)

CREATE TABLE customers(
CustomerID VARCHAR(20),
CustomerName VARCHAR(100),
Email VARCHAR(100),
PhoneNumber VARCHAR(30),
AddressLine VARCHAR(100),
City VARCHAR(20),
Country VARCHAR(20),
Postcode VARCHAR(20),
LoyaltyCard VARCHAR(3)
)

CREATE TABLE products(
ProductID VARCHAR (20),
CoffeeType VARCHAR(20),
RoastType VARCHAR(1),
Size DECIMAL(2,1),
UnitPrice DECIMAL(10,3),
PricePer100g NUMERIC,
Profit NUMERIC
)

