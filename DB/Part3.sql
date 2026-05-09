/*  Create database */
CREATE DATABASE Fanatik_3;
GO

/* Change to the Music database */
USE Fanatik_3;
GO

/* Create tables */

CREATE TABLE TRIAL1 (
    ID INTEGER PRIMARY KEY,
    NU INTEGER
)
INSERT INTO TRIAL1 VALUES(1,1)
INSERT INTO TRIAL1 VALUES(2,1)
INSERT INTO TRIAL1 VALUES(3,2)
INSERT INTO TRIAL1 VALUES(4,2)




SELECT MAX(NU)
FROM TRIAL1

DROP TABLE Components
CREATE TABLE Components (
    SKU VARCHAR(30) NOT NULL PRIMARY KEY,
    [Name] VARCHAR(20) NOT NULL,
    [Availability] varchar(30) not null,
    Material VARCHAR(12) NOT NULL DEFAULT 'Out of Stock',
    Price Money NOT NULL, 
        CONSTRAINT Money_Positive CHECK(Price>0), -- No price is negative
    [Weight] Decimal(5,2) NULL,
    [Size] Varchar(3) NULL,
    [Color] VARCHAR(10) NULL,
    BrandID SMALLINT NOT NULL,  
    [Bike Part] VARCHAR(20) NOT NULL,
);

DROP TABLE Brands
CREATE TABLE Brands(
    BrandID SMALLINT NOT NULL PRIMARY KEY,
    [Name] VARCHAR(20)
);
DROP TABLE [Created By]
CREATE TABLE [Created By] (
    BikeID SMALLINT NOT NULL,
    SKU VARCHAR(30) NOT NULL,
    PRIMARY KEY(SKU, BikeID)
);
DROP TABLE Retrieves
CREATE TABLE Retrieves (
    IP_ADDRESS VARCHAR(15) NOT NULL,
    SearchDT DATETIME2 NOT NULL,
    BrandID SMALLINT NOT NULL
    PRIMARY KEY(IP_ADDRESS,SearchDT, BrandID)
);

DROP TABLE Searches
CREATE TABLE Searches (
    IP_ADDRESS VARCHAR(15) NOT NULL,
    SearchDT DATETIME2 NOT NULL,
    Search_Text VARCHAR(30) NOT NULL
    PRIMARY KEY(IP_ADDRESS,SearchDT),
    Order_Number Integer NOT NULL,

);
DROP TABLE Customers
CREATE TABLE Customers (
    Email VARCHAR(255) NOT NULL PRIMARY KEY
        CONSTRAINT Email_Correct CHECK (Email like '%@%.%'),
    Phone_Number VARCHAR(15) NULL,
    First_Name VARCHAR(20) NULL,
    Last_Name VARCHAR(20) NULL,
    [Password] VARCHAR(30) NOT NULL,
);
DROP TABLE Orders
CREATE TABLE Orders (
    Order_Number Integer NOT NULL PRIMARY KEY,
    Order_Status VARCHAR(17) NOT NULL, 
    Order_Date DATETIME2 NOT NULL,
    Cards_Number CHAR(16) NOT NULL,
    GPS VARCHAR(30) NOT NULL,

);

DROP TABLE Includes
CREATE TABLE Includes (
    Quantity INTEGER,
    Order_Number Integer NOT NULL,
    BikeID SMALLINT NOT NULL,
    PRIMARY KEY(Order_Number, BikeID)
);
DROP TABLE Bicycles
CREATE TABLE Bicycles (
    BikeID SMALLINT NOT NULL PRIMARY KEY,
    [Name] VARCHAR(30) NOT NULL,
    [Description] VARCHAR(30) NULL
);

DROP TABLE Credit_Cards
CREATE TABLE Credit_Cards (
    Cards_Number CHAR(16) NOT NULL PRIMARY KEY,
    Exp_Date DATE,
    CVV CHAR(3) NOT NULL
        CONSTRAINT CVV_Correct CHECK ([CVV] LIKE '[0-9][0-9][0-9]'),
    Email VARCHAR(255) NOT NULL, 
    Owner_ID Char(9) NOT NULL
        CONSTRAINT Owner_ID_Correct CHECK ([Owner_ID] LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),--Makes sure format is correct
);

DROP TABLE Addresses
CREATE TABLE Addresses (
    GPS VARCHAR(30) NOT NULL PRIMARY KEY,
    Address_Country VARCHAR(20),
    Address_City VARCHAR(20),
    Address_St_Number VARCHAR(10),
    Address_Zipcode VARCHAR(8),
    Address_Home_Number VARCHAR(3),
    Email VARCHAR(255) NOT NULL,
);

-- Adding Lookup Tables:

DROP TABLE Sizes
create table Sizes(
   [size] varchar(3) not null primary key
);
alter table Components add constraint fk_size foreign key ([Size]) REFERENCES Sizes([size]);
insert into Sizes(size) values ('XXS');
insert into Sizes(size) values ('XS');
insert into Sizes(size) values ('S');
insert into Sizes(size) values ('M');
insert into Sizes(size) values ('L');
insert into Sizes(size) values ('XL');
insert into Sizes(size) values ('XXl');

DROP TABLE Available
create table Available(
   [Availability] varchar(30) not null primary key
);


alter table Components add constraint fk_Avail foreign key ([Availability]) REFERENCES Available([Availability]);


insert into Available([Availability]) values ('None in Stock');
insert into Available([Availability]) values ('In Stock');
insert into Available([Availability]) values ('Many in Stock');
insert into Available([Availability]) values ('Some in Stock');


DROP TABLE [Statuses]
create table [Statuses](
   [Status] varchar(17) not null primary key
);


alter table Orders add constraint fk_Stat foreign key (Order_Status) REFERENCES Statuses([Status]);

insert into Statuses([Status]) values ('Order Recieved');
insert into Statuses([Status]) values ('Proccessing');
insert into Statuses([Status]) values ('Sent for Delivery');

-- Adding Foreign Keys:

ALTER TABLE Components ADD CONSTRAINT Fk_BrandID FOREIGN KEY (BrandID) REFERENCES Brands(BrandID);

ALTER TABLE Searches ADD CONSTRAINT Fk_OrderNum FOREIGN KEY (Order_Number) REFERENCES Orders(Order_Number);

ALTER TABLE Retrieves ADD CONSTRAINT Fk_ret FOREIGN KEY (IP_ADDRESS, SearchDT) REFERENCES Searches(IP_ADDRESS, SearchDT);

ALTER TABLE Retrieves ADD CONSTRAINT Fk_ret1 FOREIGN KEY (BrandID) REFERENCES Brands(BrandID);

ALTER TABLE Orders ADD CONSTRAINT Fk_order FOREIGN KEY (Cards_Number) REFERENCES Credit_Cards(Cards_Number);

ALTER TABLE Includes ADD CONSTRAINT Fk_include FOREIGN KEY (Order_Number) REFERENCES Orders(Order_Number);

ALTER TABLE Includes ADD CONSTRAINT Fk_include1 FOREIGN KEY (BikeID) REFERENCES Bicycles(BikeID);

ALTER TABLE Credit_Cards ADD CONSTRAINT Fk_card FOREIGN KEY (Email) REFERENCES Customers(Email);

ALTER TABLE Addresses ADD CONSTRAINT Fk_add FOREIGN KEY (Email) REFERENCES Customers(Email);

ALTER TABLE Orders ADD CONSTRAINT Fk_ord FOREIGN KEY (GPS) REFERENCES Addresses(GPS);

-- Removing Foreign Keys:

ALTER TABLE Components DROP CONSTRAINT Fk_BrandID 

ALTER TABLE Searches DROP CONSTRAINT Fk_OrderNum 

ALTER TABLE Retrieves DROP CONSTRAINT Fk_ret 

ALTER TABLE Retrieves DROP CONSTRAINT Fk_ret1 

ALTER TABLE Orders DROP CONSTRAINT Fk_order 

ALTER TABLE Includes DROP CONSTRAINT Fk_include 

ALTER TABLE Includes DROP CONSTRAINT Fk_include1

ALTER TABLE Credit_Cards DROP CONSTRAINT Fk_card

ALTER TABLE Addresses DROP CONSTRAINT Fk_add 

ALTER TABLE Orders DROP CONSTRAINT Fk_ord

--------------------------------------------------שאילתה ללא קינון
select C.Email , A.Address_city, [Amount of searches]=count (*) ,
[rank customer] = case  when (count (*)>5) then 'MANY'  else 'LESS'
                                                       end
from    Customers as C join Addresses as A on C.Email=A.Email
            join Orders as O on A.GPS=O.GPS
           join Searches as S on S.Order_number=O.Order_number
where S.Search_Text='Raycon'
group by C.Email , A.Address_city
having count (*)>1
order by 2 ,3 desc

--------------------------------------------------שאילתה ללא קינון
select TOP 5  A.Address_Country , 
             [Amount of Customers]=Count(distinct(C.Email)) ,
             [Amount Of Orders] =count (*)
from  Customers as C join Addresses as A on C.Email=A.Email
      join Orders as O on A.GPS=O.GPS
where year(order_date)>=2021
Group by A.Address_Country
order by (count (*)) desc
--------------------------------------------------שאילתה מקוננת
SELECT TOP 20 C.SKU,C.Name , [Total Sales]=sum(price*quantityCOMP.Quantity)
FROM (
        SELECT C.BikeID ,C.SKU, Quantity=sum( I.Quantity)
        FROM Includes as I JOIN [Created by] as C on I.BikeID=C.BikeID
        GROUP BY C.BikeID,C.SKU )AS quantityCOMP
         join Components as C on quantityCOMP.SKU=C.SKU
group by C.SKU,C.Name
ORDER BY [Total Sales] DESC
--------------------------------------------------שאילתה מקוננת
select C.Availability, [amount]=count(C.Material),
[Percent]=(CAST(Count(C.Material)*100 As Decimal(6,2)))/(CAST((select Count(*)
                               from Components
                               where Material='Plastic') AS Decimal(6,2)))
from  Components as C
where C.Material='Plastic'
group by C.Availability

--------------------------------------------------שאילתה מקוננת תוך שימוש במרכיב נוסף

UPDATE Components
SET Price = 1.1 * Price
SELECT TOP 15 [Created By].SKU,[Number of Uses] = COUNT([Created By].SKU), Components.Price
FROM [Created By] JOIN Components On Components.SKU = [Created By].SKU
       GROUP BY [Created By].SKU, Components.Price
       ORDER BY [Number of Uses] DESC
--------------------------------------------------שאילתה מקוננת תוך שימוש במרכיב נוסף
select Bicycles.BikeID, [Total Price]=SUM(Components.Price)
From Bicycles JOIN [Created By] ON Bicycles.BikeID = [Created By].BikeID JOIN Components ON Components.SKU = [Created By].SKU
GROUP BY Bicycles.BikeID
EXCEPT
Select Includes.BikeID, [temp1].[Bike Price]
FROM
  (select BikeID, [Bike Price]=Sum(Components.Price)
  FROM [Created By] JOIN Components ON [Created By].SKU = Components.SKU
  GROUP BY [Created By].[BikeID]) AS temp1 JOIN Includes
ON Includes.BikeID = temp1.BikeID
GROUP BY Includes.BikeID, [temp1].[Bike Price]
ORDER BY [Total Price] DESC
--------------------------------------------------שאילתת חלון
select DISTINCT(Address_Country),Count(Address_Country) OVER (PARTITION BY Address_Country) [Number of Sales per Country],
Count(Address_Country) OVER (PARTITION BY Address_Country)*100/Count(Address_Country) OVER () [Percent of Orders]
FROM Addresses
ORDER BY [Percent of Orders] DESC
--------------------------------------------------שאילתת חלון
select O.Order_Number, [Created By].[BikeID],O.order_date, [Order Price]=Sum(Components.Price)*I.Quantity --the total price for each order
into Orders_details
FROM  Orders as O join Includes as I on O.Order_Number=I.Order_Number join [Created By] on I.BikeID=[Created By].BikeID JOIN Components ON [Created By].SKU = Components.SKU 
GROUP BY  O.Order_Number, [Created By].[BikeID], O.order_date,I.Quantity
order by  O.Order_Date


select [year]=YEAR(Order_Date), Revenue=sum([Order Price])
into [Annual Revenues]
from Orders_details
group by YEAR(Order_Date)
order by YEAR(Order_Date)

select A.year,A.Revenue,
Growth = A.Revenue/(FIRST_VALUE(Revenue) Over(Order By year))-1,
[1Year_Growth] = A.Revenue/(LAG(A.Revenue) Over(Order By Year))-1,
[Next_year_Growth] = A.Revenue/(Lead(Revenue) Over(Order By Year))-1
from [Annual Revenues] as A
drop table Orders_details
drop table [Annual Revenues]
--------------------------------------------------דוח על פסקה מורכבת
with
Activity as(
select C.Email,  LastOrder= MAX(O.[Order_Date]) , LastSearch= MAX(S.SearchDT)
from Customers as C full join Addresses as A on (C.Email=A.Email) full join Orders as O on O.GPS=A.GPS full join Searches as S on S.Order_Number=O.Order_Number
GROUP BY C.Email
),


[Quantity bicycle] as (
select CusromerOrder.Email ,Quantity=SUM(I.Quantity)
from
(select C.Email,O.Order_Number
from Customers as C full join Addresses as A on (C.Email=A.Email) full join Orders as O on O.GPS=A.GPS) as CusromerOrder full join Includes as I
   on I.Order_Number=CusromerOrder.Order_Number
group by CusromerOrder.Email
),


[Searches of Customers] as (
select Email=C.Email, S.IP_Address , S.SearchDT
from Customers as C full join Addresses as A on (C.Email=A.Email) full join Orders as O on O.GPS=A.GPS full join  Searches as S on S.Order_Number=O.Order_Number
),


[Buy Brand] as (
select Email=SC.Email, BrandID=R.BrandID
from [Searches of Customers] as SC right join Retrieves as R ON (SC.SearchDT=R.SearchDT AND SC.IP_Address=R.IP_Address)
)


select [full name]=C.First_Name + ' ' + C.Last_Name,C.Email,
[Cradit Card] = (select COUNT( DISTINCT Cards_Number) from Credit_Cards where C.Email= Credit_Cards.Email),
[last order]= (select (A.LastOrder) from Activity as A where C.Email= A.Email),
[last Search]= (select (A.LastSearch) from Activity as A where C.Email= A.Email),
[Quantity Bike]= (select Quantity from [Quantity bicycle] as Q where C.Email=  Q.Email),
[Favorite Brand]=(select Brands.name from Brands
where(Brands.BrandID=
(select top 1 BrandID from [Buy Brand] where [Buy Brand].Email=C.Email
group by [Buy Brand].BrandID
order by count([Buy Brand].BrandID))))
from Customers as C
group by C.Email, C.First_Name, C.Last_Name
order by C.First_Name ,C.Last_Name


--------------------------------------------------

