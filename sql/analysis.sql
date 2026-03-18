Customers who purchased before and after 2013?

with customer_flag as ( 
select `customer.name`,`order.date`,
case
when `order.date` < '2013-01-01' then 'before_2013'
when `order.date` >= '2013-01-01' then 'after_2013'
end as flag
from superstore),
customer_segmentation as ( select `customer.name` ,
case
when sum( case when flag = 'before_2013' then 1 else 0 end ) >0
and sum( case when flag = 'after_2013' then 1 else 0 end ) = 0
then 'churn'
when sum( case when flag = 'before_2013' then 1 else 0 end ) > 0
and sum( case when flag = 'after_2013' then 1 else 0 end ) > 0
then 'retain'
end as Customer_status 
from customer_flag
group by `customer.name`)

select cs.Customer_status,s.`customer.name`,
sum(s.sales) as 'total_sales',
sum(s.profit) as 'total_profit'
from superstore s
join customer_segmentation cs on cs.`customer.name`=s.`customer.name`

group by cs.`customer.name`,cs.Customer_status;

Count churn vs retained customers ?

with customer_flag as ( 
select `customer.name`,`order.date`,
case
when `order.date` < '2013-01-01' then 'before_2013'
when `order.date` >= '2013-01-01' then 'after_2013'
end as flag
from superstore),

customer_segmentation as ( select `customer.name` ,
case
when sum( case when flag = 'before_2013' then 1 else 0 end ) >0
and sum( case when flag = 'after_2013' then 1 else 0 end ) = 0
then 'churn'
when sum( case when flag = 'before_2013' then 1 else 0 end ) > 0
and sum( case when flag = 'after_2013' then 1 else 0 end ) > 0
then 'retain'
end as Customer_status 
from customer_flag
group by `customer.name`)
select Customer_status , count(*) as total_count from customer_segmentation
group by Customer_status;

Sales by category ?
with customer_flag as ( 
select `customer.name`,`order.date`,
case
when `order.date` < '2013-01-01' then 'before_2013'
when `order.date` >= '2013-01-01' then 'after_2013'
end as flag
from superstore),

customer_segmentation as ( select `customer.name` ,
case
when sum( case when flag = 'before_2013' then 1 else 0 end ) >0
and sum( case when flag = 'after_2013' then 1 else 0 end ) = 0
then 'churn'
when sum( case when flag = 'before_2013' then 1 else 0 end ) > 0
and sum( case when flag = 'after_2013' then 1 else 0 end ) > 0
then 'retain'
end as Customer_status 
from customer_flag
group by `customer.name`)
select Customer_status , count(*) as total_count from customer_segmentation
group by Customer_status;

Profit margin by category ?
SELECT Category, SUM(sales) AS Total_sales
FROM superstore
GROUP BY Category;

Which products drive 80% of profit?;

select * from 
(
select `product.name`,Total_profit, sum(total_profit) over( order by Total_profit desc) as Running_profit,
sum(Total_profit) over()  as overall_profit,
round((sum(total_profit) over( order by Total_profit desc)/sum(Total_profit) over()) * 100,2) as cummulative_profit_pct
from (
select  `product.name`,sum(profit) as Total_profit from superstore
group by `product.name`)x)p
where cummulative_profit_pct <= 80;

select count(*) from (
select `product.name`,Total_profit, sum(total_profit) over( order by Total_profit desc) as Running_profit,
sum(Total_profit) over()  as overall_profit,
round((sum(total_profit) over( order by Total_profit desc)/sum(Total_profit) over()) * 100,2) as cummulative_profit_pct
from ( select `product.name`,sum(profit) as Total_profit from superstore
group by `product.name`)p)x
where cummulative_profit_pct <= 80;

Which product categories generate the most profit, and what percentage of total profit does each category contribute?;

select category, Total_profit, round(Total_profit/sum(Total_profit)over()*100,2) as Profit_pct
from(
select category,sum(profit) as Total_profit from
superstore
group by Category)x;

Which regions are selling a lot but generating low profit margin?;

Select Region, Total_sales, Total_profits, round(Total_profits/Total_sales *100,2 ) as Profit_margin
from 
(select region,sum(sales) as Total_sales, sum(profit) as Total_profits from
superstore
group by region)x
order by Profit_margin asc; 

How many unique customers purchased in each year?;

select  year(`order.date`) , count(distinct `customer.name`) as Total_unique_customers from superstore
group by year(`order.date`);

Customers who purchased in 2011 AND also purchased in 2012;

select count(*) as retained_customers from (
select `customer.name` from superstore
where  year(`order.date`) in (2011,2012)
group by `customer.name`
having count(distinct year(`order.date`)) =2)x;

How did sales grow year over year?;

select year_sales, current_sales, previous_sales
, round((current_sales - previous_sales)/(previous_sales) *100,2) as MOM_growth
from (
select  year_sales,current_sales,
lag(current_sales)over(order by year_sales) as previous_sales
 from ( select
 year(`order.date`) as year_sales,
 sum(sales) as current_sales
 from superstore
group by year(`order.date`))x)t;

Which customers generate high sales but very low profit margins?;

select `customer.name`, sum(sales) as Total_sales, sum(profit) as Total_profit,
round(sum(profit)/sum(sales) * 100,2) as Profit_margin
from superstore
group by `customer.name`
order by Profit_margin asc;

Customer + Discount behavior analysis;
| Customer | Avg Discount | Sales | Profit | Margin |;

select `customer.name`, round(avg(discount),2) as avg_discount, sum(sales) as Total_sales, sum(profit) as Total_profit,
round(sum(profit)/sum(sales) * 100,2) as Profit_margin
from superstore
group by `customer.name`
order by avg_discount desc;

| Category | Avg Discount | Sales | Profit | Margin |;

select Category, round(avg(discount),2) as avg_discount, sum(sales) as Total_sales, sum(profit) as Total_profit,
round(sum(profit)/sum(sales) * 100,2) as Profit_margin
from superstore
group by Category
order by avg_discount desc;



