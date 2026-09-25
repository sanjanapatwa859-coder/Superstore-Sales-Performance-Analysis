USE superstore_db;

SHOW TABLES;

SELECT COUNT(*) FROM superstore;

SELECT * FROM superstore ;

-- Total Revenue, Total Profit, Orders, and Average Discount
SELECT
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(AVG(Profit_Margins_Percentage), 2) AS Avg_Profit_Margin_Pct,
    ROUND(AVG(Discount) * 100, 2) AS Avg_Discount_Pct
FROM superstore;

-- Category-wise Sales & Profit Breakdown
SELECT 
    Category,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) AS Profit_Margin_Pct
FROM superstore
GROUP BY Category
ORDER BY Total_Profit DESC;

-- Regional Sales Performance
SELECT 
    Region,
    ROUND(SUM(Sales), 2) AS Regional_Sales,
    ROUND(SUM(Profit), 2) AS Regional_Profit,
    ROUND(AVG(Profit_Margins_Percentage), 2) AS Avg_Margin
FROM superstore
GROUP BY Region
ORDER BY Regional_Sales DESC;

-- Monthly Sales & Profit Trend Analysis
SELECT 
    Year,
    Month,
    ROUND(SUM(Sales), 2) AS Monthly_Sales,
    ROUND(SUM(Profit), 2) AS Monthly_Profit
FROM superstore
GROUP BY Year, Month
ORDER BY Year, Month;

-- Year-over-Year (YoY) Sales Growth (Window Function)
WITH Yearly_Sales AS (
    SELECT 
        Year,
        ROUND(SUM(Sales), 2) AS Current_Year_Sales
    FROM superstore
    GROUP BY Year
)
SELECT 
    Year,
    Current_Year_Sales,
    LAG(Current_Year_Sales, 1) OVER (ORDER BY Year) AS Previous_Year_Sales,
    ROUND(((Current_Year_Sales - LAG(Current_Year_Sales, 1) OVER (ORDER BY Year)) 
            / LAG(Current_Year_Sales, 1) OVER (ORDER BY Year)) * 100, 2) AS YoY_Growth_Pct
FROM Yearly_Sales;

-- Running Total (Cumulative Sales Over Time)
SELECT 
    Order_Date,
    ROUND(SUM(Sales), 2) AS Daily_Sales,
    ROUND(SUM(SUM(Sales)) OVER (ORDER BY Order_Date), 2) AS Cumulative_Sales
FROM superstore
GROUP BY Order_Date
ORDER BY Order_Date;

-- Loss-Making Sub-Categories (Discount Analysis)
SELECT 
    Category,
    Sub_Category,
    ROUND(AVG(Discount) * 100, 2) AS Avg_Discount_Pct,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM superstore
GROUP BY Category, Sub_Category
HAVING Total_Profit < 0
ORDER BY Total_Profit ASC;

-- Top 5 Highest & Lowest Profit-Making Products
(SELECT 
    'Top Profit' AS Type,
    Product_Name,
    Category,
    ROUND(SUM(Profit), 2) AS Total_Profit
 FROM superstore
 GROUP BY Product_Name, Category
 ORDER BY Total_Profit DESC
 LIMIT 5)
UNION ALL
(SELECT 
    'Top Loss' AS Type,
    Product_Name,
    Category,
    ROUND(SUM(Profit), 2) AS Total_Profit
 FROM superstore
 GROUP BY Product_Name, Category
 ORDER BY Total_Profit ASC
 LIMIT 5);

-- High Discount vs Zero Discount Sales Impact
SELECT 
    CASE 
        WHEN Discount = 0 THEN 'No Discount (0%)'
        WHEN Discount > 0 AND Discount <= 0.2 THEN 'Low Discount (1-20%)'
        WHEN Discount > 0.2 AND Discount <= 0.5 THEN 'Medium Discount (21-50%)'
        ELSE 'High Discount (>50%)'
    END AS Discount_Band,
    COUNT(*) AS Total_Orders,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(AVG(Profit_Margins_Percentage), 2) AS Avg_Profit_Margin
FROM superstore
GROUP BY Discount_Band
ORDER BY Total_Profit DESC;

-- Top 10 High-Value Customers (Customer Lifetime Value)
SELECT 
    Customer_ID,
    Customer_Name,
    Segment,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    ROUND(SUM(Sales), 2) AS Total_Spent,
    ROUND(SUM(Profit), 2) AS Total_Profit_Generated
FROM superstore
GROUP BY Customer_ID, Customer_Name, Segment
ORDER BY Total_Spent DESC
LIMIT 10;

-- Customer RFM Analysis (Recency, Frequency, Monetary)
SELECT 
    Customer_ID,
    Customer_Name,
    DATEDIFF((SELECT MAX(Order_Date) FROM superstore), MAX(Order_Date)) AS Recency_Days,
    COUNT(DISTINCT Order_ID) AS Frequency_Orders,
    ROUND(SUM(Sales), 2) AS Monetary_Value
FROM superstore
GROUP BY Customer_ID, Customer_Name
ORDER BY Monetary_Value DESC
LIMIT 10;

-- Shipping Mode Efficiency & Delay Analysis
SELECT 
    Ship_Mode,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    ROUND(AVG(DATEDIFF(Ship_Date, Order_Date)), 2) AS Avg_Shipping_Days,
    ROUND(SUM(Sales), 2) AS Total_Sales
FROM superstore
GROUP BY Ship_Mode
ORDER BY Avg_Shipping_Days ASC;

-- Top 3 Selling Sub-Categories Per Region (Dense Rank)
WITH Ranked_SubCats AS (
    SELECT 
        Region,
        Sub_Category,
        ROUND(SUM(Sales), 2) AS Total_Sales,
        DENSE_RANK() OVER (PARTITION BY Region ORDER BY SUM(Sales) DESC) AS Sales_Rank
    FROM superstore
    GROUP BY Region, Sub_Category
)
SELECT 
    Region,
    Sub_Category,
    Total_Sales,
    Sales_Rank
FROM Ranked_SubCats
WHERE Sales_Rank <= 3;

-- Top 5 Most Profitable States
SELECT 
    State,
    Country,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) AS Profit_Margin_Pct
FROM superstore
GROUP BY State, Country
ORDER BY Total_Profit DESC
LIMIT 5;

-- Repeat Purchase Rate (Customers With >1 Order)
WITH Customer_Orders AS (
    SELECT 
        Customer_ID,
        COUNT(DISTINCT Order_ID) AS Order_Count
    FROM superstore
    GROUP BY Customer_ID
)
SELECT 
    COUNT(CASE WHEN Order_Count > 1 THEN 1 END) AS Repeat_Customers,
    COUNT(*) AS Total_Customers,
    ROUND((COUNT(CASE WHEN Order_Count > 1 THEN 1 END) / COUNT(*)) * 100, 2) AS Repeat_Purchase_Rate_Pct
FROM Customer_Orders;