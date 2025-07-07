
-- Phase 1: Data Exploration & Validation

SELECT TOP 10 *
FROM RetailStore..Salesdata 

--Count Total Transactions

Select*
from RetailStore..Salesdata

select COUNT(Transaction_ID)
from RetailStore..Salesdata

--Count of Unique Customers

select COUNT(DISTINCT Customer_ID) as uniquecustomer
from RetailStore..Salesdata

-- Find the Date Range of Sales

select min(Date), max(date)
from RetailStore..Salesdata

--Total Sales (Revenue)

select sum(Total_Amount) as Revenue
from RetailStore..Salesdata

--Total Quantity of Items Sold

select sum(Quantity)
from RetailStore..Salesdata


--Phase 2: Descriptive Analytics


--Sales by Product Category

select Product_Category,sum(Total_Amount) as Sales
from RetailStore..Salesdata
group by Product_Category
ORDER BY Sales DESC

--Sales by Gender

select Gender, sum(Total_Amount)
from RetailStore..Salesdata
group by Gender
order by 1 desc

--Monthly Sales Trend

SELECT 
  FORMAT(Date, 'yyyy-MM') AS Month,
  SUM(Total_Amount) AS Total_Sales
FROM RetailStore..Salesdata
GROUP BY FORMAT(Date, 'yyyy-MM')
ORDER BY Month;

--Average Order Value

select *
from RetailStore..Salesdata

select avg(Total_Amount)
from RetailStore..Salesdata

--Top 5 Transactions by Total Amount

SELECT TOP 5 
  Transaction_ID, 
  Customer_ID, 
  Total_Amount
FROM RetailStore..Salesdata
ORDER BY Total_Amount DESC;

--Top 5 Most Frequently Purchased Product Categories

select Top 5 Product_Category ,sum(Quantity)
from RetailStore..Salesdata
group by Product_Category
order by 1 desc

--Customer Segmentation by Age Group

select case 
when age between 18 and 24 then '18-24'
when age between 25 and 32 then '25-32'
when age between 33 and 40 then '33-40'
when age between 41 and 50 then '41-50'
when age >= 51 then '50+'
else 'Unknown'
end as Age, sum(Total_Amount) as Sales
from RetailStore..Salesdata
group by case 
when age between 18 and 24 then '18-24'
when age between 25 and 32 then '25-32'
when age between 33 and 40 then '33-40'
when age between 41 and 50 then '41-50'
when age >= 51 then '50+'
else 'Unknown'
end
order by 1 

--Identify Repeat Customers

SELECT 
  Customer_ID,
  COUNT(Transaction_ID) AS Number_of_Transactions,
  SUM(Total_Amount) AS Total_Spent
FROM RetailStore..Salesdata
GROUP BY Customer_ID
HAVING COUNT(Transaction_ID) > 1
ORDER BY Number_of_Transactions DESC;


--First Purchase Month (Cohort Analysis Start)

select  Customer_ID,FORMAT(min(date),'yyyy-MM') as month
from RetailStore..Salesdata
group by Customer_ID
order by 1

--Monthly Revenue Trend  (with Running Total)

With MonthlyRevenue as (
select
FORMAT(date,'yyyy-MM') As Months, 
sum(Total_Amount) As MonthlySales 
from RetailStore..Salesdata
group by FORMAT(date,'yyyy-MM')
)

select Months , MonthlySales, sum(MonthlySales) over (order by months)
from MonthlyRevenue

--Gender-wise Monthly Sales Trend

select *
from RetailStore..Salesdata

select FORMAT (Date,'yyyy-MM') Months ,gender, Sum(Total_Amount) sales
from RetailStore..Salesdata
group by FORMAT (Date,'yyyy-MM'),Gender
order by Months,Gender

--Monthly New vs Repeat Customers

With FirstMonthPurchase as (
select FORMAT(min(date),'yyyy-MM') As Months ,Customer_id
from RetailStore..Salesdata
group by Customer_ID
),
CustomerType as (
select s.Customer_ID, FORMAT(s.Date,'yyyy-MM') As PurchaseMonth, 
case when FORMAT(s.Date,'yyyy-MM') = f.Months then 'New' else 'Repeat' end as CustomerStatus
from RetailStore..Salesdata s
join FirstMonthPurchase f on s.Customer_ID = f.Customer_ID
)
select PurchaseMonth , CustomerStatus , COUNT (Distinct Customer_ID) as CustomerCount
from CustomerType
group by PurchaseMonth,CustomerStatus
order by 1,2


--Monthly Revenue by Product Category

select Product_Category, FORMAT(date, 'yyyy-MM') AS Months ,Sum(Total_Amount)
from RetailStore..Salesdata
Group by Product_Category,FORMAT(date, 'yyyy-MM')
order by 1

--Monthly Active Customers

SELECT 
  FORMAT(Date, 'yyyy-MM') AS Month,
  COUNT(DISTINCT Customer_ID) AS Active_Customers
FROM RetailStore..Salesdata
GROUP BY FORMAT(Date, 'yyyy-MM')
ORDER BY Month;


--Monthly Revenue by Gender

select *
from RetailStore..Salesdata

select FORMAT(Date,'yyyy-MM') Months , Gender, Sum (Total_Amount) Revenue 
from RetailStore..Salesdata
group by FORMAT(Date,'yyyy-MM') , Gender
order by 1, 2

-- Calculate Average Order Value (AOV) Per Month

Select FORMAT(date,'yyyy-MM') as Months, round(Sum(Total_Amount) / COUNT(Transaction_ID),0) 
from RetailStore..Salesdata
group by FORMAT(date,'yyyy-MM')
order by 1

--Monthly Revenue Trend by Product Category

select  Product_Category , FORMAT(date, 'yyyy-MM') As Months , sum(Total_Amount)
from RetailStore..Salesdata
group by FORMAT(date, 'yyyy-MM') , Product_Category
order by 1,2

--Monthly Quantity Sold per Product Category

select FORMAT(date,'yyyy-MM') as Months ,Product_Category, Sum(Quantity)
from RetailStore..Salesdata
group by FORMAT(date,'yyyy-MM'),Product_Category
order by 1,2

--Monthly Revenue and Quantity Sold Trend

select FORMAT(date,'yyyy-MM') as Months , sum(Quantity) , sum(Total_Amount)
from RetailStore..Salesdata
group by FORMAT(date,'yyyy-MM')
order by 1

--Top 10 Highest Spending Customers

select Top 10 Customer_ID , sum(Total_Amount) as spending
from RetailStore..Salesdata
group by Customer_ID
order by 2 desc 

--Average Basket Size

select  sum(Quantity)/COUNT(Transaction_ID) 
from RetailStore..Salesdata

--Customer Churn Indicator

With LatestDate as (
select max(date) as MaxDate from RetailStore..Salesdata
),
LatestPurchase as (
select Customer_ID ,max(date) as LatestPurchaseDate
from RetailStore..Salesdata
group by Customer_ID
)
select customer_id, LatestPurchaseDate,
case when LatestPurchaseDate < DATEADD(MONTH,-3 ,(select maxdate from Latestdate)) then 'Churned' else 'Active' End as Customer_Status
from LatestPurchase 
order by Customer_Status desc,LatestPurchaseDate


--RFM Segmentation (Recency, Frequency, Monetary)

With LatestDate as(
select max(date) As LatestDate
from RetailStore..Salesdata),
RFM_table as(
select Customer_ID , DATEDIFF(day,max(date),(select max(date)from LatestDate)) as Recency,
Count(Transaction_ID) as Frequency,sum(Total_Amount) as Monetary
from RetailStore..Salesdata
group by Customer_ID
),
--RFM Scoring
RFM_scored as (
select Customer_ID,
        Recency,
        Frequency,
        Monetary,
NTILE(4) over (order by recency desc) as R_score,
NTILE(4) over (order by Frequency asc) as F_score,
NTILE(4) over (order by Monetary asc) as M_score
from RFM_table
),
Fina_Rfm as(
select customer_id,Recency,Frequency,Monetary,R_score,F_score,M_score,CONCAT(R_score,F_score,M_score) as RFM_segment
from RFM_scored )
-- Summary Table by RFM Segment
select RFM_segment , COUNT (Customer_ID) as TotalCustomer , 
round(avg(Recency),0) as AvgRecency ,
Round(avg(Frequency),0) as AvgFrequency,
Round(avg(Monetary),0) as AvgMonetary
from Fina_Rfm
group by RFM_segment
order by RFM_segment
