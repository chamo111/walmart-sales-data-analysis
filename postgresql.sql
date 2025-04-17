SELECT * FROM walmart;

DROP TABLE walmart;

SELECT COUNT(*) FROM walmart;

SELECT 
   payment_method,
   count(*)
FROM walmart
group by payment_method

select 
     count (distinct branch)
from walmart;


--- business problem

-- q1. find different payment method
select payment_method
from walmart
group by payment_method;

--number of transactions
select count(*)
from walmart;


--number of qty sold
select payment_method,
    count(*) as no_payments,
    sum(quantity) as no_qty_sold 
from walmart
group by payment_method;


--identify the highest rated category in each branch, displaying the branch, category, avg rating
select *
from (
select branch,
     category,
	 avg(rating) as avg_rating,
	 rank() over(partition by branch order by avg(rating) desc) as rank
from walmart
group by 1,2
)
where rank = 1


--identify the busiest day for each branch on the number of transactions

select *
from(
select branch,
   TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'day') as day_name,
   count(*) as no_transactions,
   rank() over (partition by branch order by count(*) desc) as rank
from walmart
group by 1,2
)
where rank = 1


-- calculate the total qty of items sold per payment method. list payment_methos and total_quantity
select * from walmart;

select payment_method,
    -- count(*) as no_payments,
    sum(quantity) as no_qty_sold 
from walmart
group by payment_method;


-- determine the average, minimum & maximum rating of category for each city. list the city, average_rating, 
-- min_rating & max_rating
select city,
       category,
       avg(rating) as average_rating,
	   min(rating) as min_rating,
	   max(rating) as max_rating
from walmart
group by 1, 2


-- calculate the total profit for each category by considering total_profit as (unit_price * quantity * profit_margin).
-- list category and total_profit, ordered from highest to lowest profit.
select category,
      sum(total) as total_revenue,
      sum(total* profit_margin) as profit
from walmart
group by 1
order by 3 desc


-- determine the most common payment method for each branch. dispaly branch and the prefered_payment method
select*
from (
select branch,
      payment_method,
	  count(*) as total_transactions,
	  rank() over (partition by branch order by count(*) desc) as rank
from walmart
group by 1,2
order by 1,2 desc
)
where rank = 1


-- categorize sales into 3 groups: morning, afternoon, evening
-- find out which of the shift and numbers of invoices
select branch,
  case 
     when extract (hour from(time::time)) <12 then 'morning'
     when extract (hour from(time::time)) between 12 and 17 then 'afternoon'
     else 'evening'
  end day_time,
  count(*)
from walmart
group by 1,2
order by 1,3 desc

-- identify 5 branch with highest decrease ratio in revenue compare to last year 
-- (current year 2013 & last year 2022)
with revenue_2022
as
(
  select branch,
     sum(total) as revenue
  from walmart
  where extract(year from TO_DATE(date, 'dd/mm/yy')) = 2022 --psql
  -- where year(TO_DATE(date, 'dd/mm/yy')) = 2022 --mysql
  group by 1
),
revenue_2023
as
(
  select branch,
     sum(total) as revenue
  from walmart
  where extract(year from TO_DATE(date, 'dd/mm/yy')) = 2023
  group by 1
)
select 
   ls.branch,
   ls.revenue as last_year_revenue,
   cs.revenue as current_year_revenue,
   round((ls.revenue - cs.revenue)::numeric/ls.revenue::numeric * 100 ,2) as revenue_desc_ratio
from revenue_2022 as ls
join
revenue_2023 as cs
on ls.branch = cs.branch
where
   ls.revenue > cs.revenue
order by 4 desc
limit 5 --top 5











