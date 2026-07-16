use sql_quest;

select product_name,price
from products
where price>(select avg(price)
from products);

select product_name,stock
from products
 where stock < (select avg(stock)
from products);

select c.customer_id,
c.customer_name, 
count(o.order_id) as total_orders
from customers c join orders o
 on c.customer_id=o.customer_id 
 group by customer_id,customer_name
 having count(o.order_id) >
 (select avg(total_orders)
 from 
    (select customer_id, 
    count(*) as total_orders
from orders
group by customer_id) as customer_order);


select customer_id,
customer_name
from customers
where customer_id not IN(
select customer_id
 from orders);
 
 select 
 product_id,
 product_name
 from 
 products
 where product_id
 not in( select product_id from order_items);
 
 select customer_name ,customer_id
 from customers 
 where customer_id 
 in 
 (select o.customer_id
 from orders o join payments p 
 on o.order_id = p.order_id
 where amount > 50000);
 
 select customer_id,
 customer_name
 from customers c
 where EXISTS
 (select 1
 from orders o
 where
 o.customer_id = c.customer_id);
 
 select product_id,
 product_name
 from products p
 where
  not exists (select 1
 from order_items o
 where o.product_id = p.product_id);
 
select product_id,product_name,
price
from products p 
where price >
 (select avg(p2.price)
 from products p2
 where p2.category_id = p.category_id);
 

select *
from 
(select c.customer_id,
c.customer_name,
sum(p.amount) as total_spending 
from customers c
join orders o on c.customer_id = o.customer_id
join payments p
on o.order_id = p.order_id
group by c.customer_id,c.customer_name) as customer_totals

where total_spending > 
(select avg(total_spending)
from ( select c.customer_id,
sum(p.amount) as total_spending
from customers c
join orders o on c.customer_id = o.customer_id
join payments p
on o.order_id = p.order_id
group by c.customer_id) as avg_totals);



select customer_id, customer_name, 
total_orders from (
select c.customer_id,
c.customer_name,
count(order_id) as total_orders
from customers c join orders o on
c.customer_id = o.customer_id
group by c.customer_id,c.customer_name) as total_orders
where total_orders >
(select avg(total_orders) 
from 
(select c.customer_id,
count(order_id) as total_orders
from customers c
join orders o on c.customer_id = o.customer_id
group by c.customer_id) as avg_totals);
 
 
 select c.customer_id,
 c.customer_name, 
 (select count(order_id)
 from orders o 
 where o.customer_id = c.customer_id) as total_orders
 from customers c; 
 
 select c.customer_id,
 c.customer_name,
 (select count(order_id)
 from orders o where c.customer_id = o.customer_id 
 ) as total_orders,
 (select sum(amount)
 from orders o join
 payments p on o.order_id = p.order_id
 where 
 o.customer_id = c.customer_id) as total_spend
 from customers c;