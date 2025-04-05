-- create database
CREATE DATABASE pizza_databse;

-- create table 
CREATE TABLE orders (
order_id INT PRIMARY KEY,
order_date DATE ,
order_time TIME
);

CREATE TABLE order_details (
order_details_id INT PRIMARY KEY,
order_id INT ,
pizza_id VARCHAR(30),
quantity INT
);

-- data exploration

-- Retrieve the total number of orders placed.
select count(order_id) as total_num_of_order_placed from orders;

-- Data Analysis and Business key problems & answers 

-- Calculate the total revenue generated from pizza sales.
select round(sum(o.quantity * p.price),2) as total_revenue 
from order_details as o
join pizzas as p 
on o.pizza_id = p.pizza_id ;

-- Identify the most common pizza size ordered.
select p.size, count(o.order_id) as total_order
from order_details as o
join pizzas as p 
on o.pizza_id = p.pizza_id 
group by p.size
order by total_order desc 
limit 1;

-- List the top 5 most ordered pizza types along with their quantities.
select t.name as pizza_name, t.pizza_type_id as pizza_type ,sum( o.quantity) as total_orders
from order_details as o
join pizzas as p on o.pizza_id = p.pizza_id 
join pizza_types as t on p.pizza_type_id = t.pizza_type_id 
group by pizza_name, pizza_type
order by total_orders desc
limit 5;

-- which day of the week are the most orders placed.
select dayname(order_date) as day_name, count(order_id) as total_orders
from orders 
group by day_name
order by total_orders desc
limit 1 ;

-- determine the best and worst month in terms of order volume
select month(order_date) as month, count(order_id) as total_orders
from orders 
group by month 
order by total_orders desc 
limit 1;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
select t.category as pizza_category, sum(o.quantity) as total_quantity
from order_details as o
join pizzas as p on o.pizza_id = p.pizza_id 
join pizza_types as t on p.pizza_type_id = t.pizza_type_id 
group by pizza_category
order by total_quantity desc;

-- Determine the distribution of orders by hour of the day.
select hour(order_time) as order_hour, count(order_id) as total_orders 
from orders 
group by order_hour 
order by order_hour;

-- Join relevant tables to find the category-wise distribution of pizzas.
select category as pizza_category, count(pizza_type_id) as total_pizzas
from pizza_types
group by pizza_category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
with avg_pizza_order as(
select o.order_date, sum(d.quantity) as total_orders_per_day
from orders as o
join order_details as d on o.order_id = d.order_id 
group by o.order_date
)
select round(avg(total_quantity),0) as average_pizza_order
from avg_pizza_order;

-- Determine the top 3 most ordered pizza types based on revenue.
select p.pizza_type_id as pizza_type, t.name as pizza_name, round(sum(p.price * o.quantity),2) as total_revenue 
from order_details as o
join pizzas as p on o.pizza_id = p.pizza_id 
join pizza_types as t on p.pizza_type_id = t.pizza_type_id
group by pizza_type, pizza_name
order by total_revenue desc 
limit 3;

-- Determine the top 3 Least ordered pizza types based on revenue.
select p.pizza_type_id as pizza_type, t.name as pizza_name, round(sum(p.price * o.quantity),2) as total_revenue 
from order_details as o
join pizzas as p on o.pizza_id = p.pizza_id 
join pizza_types as t on p.pizza_type_id = t.pizza_type_id
group by pizza_type, pizza_name
order by total_revenue desc 
limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
with category_wise_revenue as (
select t.category as pizza_category, sum(p.price * o.quantity) as total_revenue
from order_details as o
join pizzas as p on o.pizza_id = p.pizza_id 
join pizza_types as t on p.pizza_type_id = t.pizza_type_id 
group by pizza_category
)
select pizza_category ,total_revenue,
ROUND((total_revenue *100) / (select SUM(total_revenue) from category_wise_revenue),2) as percentage_of_revenue
from category_wise_revenue
order by percentage_of_revenue desc;

-- Analyze the cumulative revenue generated over time.
with revenue as (
select o.order_date as order_date, round(sum(d.quantity * p.price),2) as total_revenue
from orders as o 
join order_details as d on o.order_id = d.order_id 
join pizzas as p on d.pizza_id = p.pizza_id 
group by order_date
)
select order_date, total_revenue,
sum(total_revenue) over(order by order_date) as cumulative_revenue 
from revenue 
order by order_date;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
with best_selling_pizzas as(
select  t.category as pizza_category, t.pizza_type_id as pizza_types, sum(o.quantity * p.price) as total_revenue,
rank() over (partition by t.category order by sum(o.quantity * p.price) desc) as rnk
from order_details as o
join pizzas as p on o.pizza_id = p.pizza_id 
join pizza_types as t on p.pizza_type_id = t.pizza_type_id
group by pizza_category,pizza_types
)
select pizza_category, pizza_types, total_revenue,rnk
from revenue 
where rnk <=3
order by pizza_category, rnk;

