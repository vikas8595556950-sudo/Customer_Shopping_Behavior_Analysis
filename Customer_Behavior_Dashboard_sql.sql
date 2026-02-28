create database customer_behaviour;
select * from customer;
-- Q1 WHAT IS THE TOTAL REVENUE GENERATE BY MALE AND FEMALE

SELECT GENDER,sum(PURCHASE_AMOUNT) Total_Revenue FROM CUSTOMER GROUP BY GENDER ;

-- Q2 WHICH CUSTOMER USED A DISCOUNT BUT STLL SPENT MORE THAN THE AVERAGE PURCHASE AMOUNT?
SELECT 
    customer_id, purchase_amount
FROM
    customer
WHERE
    discount_applied = 'yes'
        AND purchase_amount >= (SELECT 
            AVG(purchase_amount)
        FROM
            customer);
            
            
-- Q3 which are the top 5 product with the highest average review rating?
SELECT 
    item_purchased, ROUND(AVG(review_rating), 2)
FROM
    customer
GROUP BY item_purchased
ORDER BY AVG(review_rating) DESC
LIMIT 5;

-- Q4 Compare the average purchase amount between Standard and Express Shipping

SELECT 
    shipping_type, AVG(purchase_amount)
FROM
    customer
WHERE
    shipping_type IN ('express' , 'standard')
GROUP BY shipping_type;


-- Q5 do subscribe customer spend more? compare avg spend and total revenue between subscibers and non subsciber
SELECT 
    COUNT(customer_id) total_customer,
    subscription_status,
    AVG(purchase_amount),
    SUM(purchase_amount) total_revenue
FROM
    customer
GROUP BY subscription_status
ORDER BY total_revenue;


-- Q6 which 5 product have highest percentage of purchase with discount applied?
SELECT 
    item_purchased,
    ROUND(100 * SUM(CASE
                WHEN discount_applied = 'yes' THEN 1
                ELSE 0
            END) / COUNT(*),
            2) AS discount_rate
FROM
    customer
GROUP BY item_purchased
ORDER BY discount_rate DESC
LIMIT 5;

-- Q7 segment customers into new, returning , and loyal based on thier total 
-- number of previous purchase , and show the count of each segment
with customer_type as (
    select 
        customer_id,
        previous_purchases,
        case 
            when previous_purchases = 1 then "new"
            when previous_purchases between 2 and 10 then "returning"
            else "loyal"
        end as customer_segment
    from customer
)
select 
    customer_segment,
    count(*) as number_of_customer
from customer_type
group by customer_segment;


#Q8 what are the top 3 most purchased product of each category?
WITH item_count AS (
    SELECT 
        item_purchased,
        category,
        COUNT(customer_id) AS total_orders,
        ROW_NUMBER() OVER (
            PARTITION BY category 
            ORDER BY COUNT(customer_id) DESC
        ) AS rnk
    FROM customer
    GROUP BY category, item_purchased
)
SELECT 
    rnk,
    category,
    item_purchased,
    total_orders
FROM item_count
WHERE rnk <= 3;

-- Q9 are customers who are repeat buyers (more than 5 previous purchases) also likely to subscibe

select subscription_status, count(customer_id) return_buyers from customer where previous_purchases>5
group by subscription_status;

-- Q10  what is the reveue contributuion of each age group?
select age_group, sum(purchase_amount) from customer group by age_group;