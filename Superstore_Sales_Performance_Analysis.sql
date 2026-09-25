USE superstore_db;

SHOW TABLES;

SELECT COUNT(*) FROM superstore;

SELECT * FROM superstore LIMIT 10;

-- total sales & profit --
select sum(sales) as TotalSales
from  superstore;

select sum(profit) as TotalProfit
from superstore;

-- total orders --
select count(Distinct Order_ID) as TotalOrders
from superstore;

-- Average Order Value --
select sum(sales)/count(Distinct Order_ID) as AvgOrderValue 
from superstore;

select * from superstore;

-- top 10 products by sales --

select Product_Name, sum(Sales) as Revenue
from superstore
group by Product_Name
order by Revenue desc
limit 10;

-- Low_Performing Products(Negative profit)
select Product_name, sum(sales) as Revenue, sum(profit) as Profit
from superstore
group by Product_Name
having sum(profit) < 0
order by Profit ASC;

-- Category Contribution --
select Category, sum(sales) as Revenue, sum(profit) as Profit
from superstore
group by Category;

-- Sub Category --
SELECT Sub_Category, sum(sales) as Revenue, sum(profit) as Profit
from superstore
group by Sub_Category
order by Revenue DESC;

--  Top 10 Customers by Spending --
select Customer_Name, sum(sales) as TotalSpend
from superstore
group by Customer_Name
order by TotalSpend DESC
limit 10;

-- Customer Segment --
select Segment, sum(sales) as Revenue, sum(profit) as Profit
from superstore
group by Segment;

-- Repeat Customer --
Select Customer_ID, count(Order_ID) as OrderCounts
from superstore
group by Customer_ID
order by OrderCounts DESC;

-- Regional Sales --
select Region ,sum(sales) as Revenue, sum(profit) as Profit
from superstore
group by Region;

select * from superstore;

-- State Wise Sales-- 
select State, sum(sales) as Revenue, sum(profit) as Profit
from superstore
group by State
order by Revenue DESC;

-- City Wise Sales --
Select City, sum(sales) as Revenue, sum(profit) as Profit
from superstore
group by City
order by Revenue DESC;

-- Monthly Sales Trend --
Select Month, sum(sales) as MonthlySales
from superstore
group by Month
order by MonthlySales DESC;

-- Yearly Growth --
select Year, sum(sales) as YearlySales, sum(profit) as YearlyProfit
from superstore
group by Year;

-- Quarterly Sales --
select Quarter, sum(sales) as QuarterlySales
from superstore
group by Quarter;

-- Discount Impact --
select Discount, avg(profit) as AvgProfit
from superstore
group by Discount
order by AvgProfit DESC;

-- Profit Margin by Category --
SELECT Category, AVG(Profit/Sales)*100 
FROM superstore 
GROUP BY Category;

-- Top 10 Most Profitable Products --
SELECT Product_Name, SUM(Profit) as Revenue
FROM superstore 
GROUP BY Product_Name
ORDER BY Revenue DESC
LIMIT 10;

