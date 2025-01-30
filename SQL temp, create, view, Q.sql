use sakila;

-- In this exercise, you will create a customer summary report that summarizes key information about customers in the Sakila database,
-- including their rental history and payment details. The report will be generated using a combination of views, CTEs, and temporary tables.

-- Step 1: Create a View
-- first, create a view that summarizes rental information for each customer. The view should include the customer's ID, name,
-- email address, and total number of rentals (rental_count).

create view customers_view as (
    select customer_id, c.first_name, c.last_name, c.email, count(r.rental_id) as rental_count
    from customer c
    inner join rental r using(customer_id)
    group by customer_id, c.first_name, c.last_name, c.email)
    ;
-- Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid).
-- The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate
-- the total amount paid by each customer.

create temporary table total_paid as
select cv.customer_id, cv.first_name, cv.last_name, round(sum(p.amount), 0) as total_paid
from customers_view cv
inner join payment p on cv.customer_id = p.customer_id
group by cv.customer_id, cv.first_name, cv.last_name;

-- Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in
-- Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid.
-- Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email,
-- rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.

with customer_summary as (
    select 
        cv.customer_id,
        cv.first_name,
        cv.last_name,
        cv.email,
        cv.rental_count,
        tp.total_paid
    from customers_view cv
    inner join total_paid tp on cv.customer_id = tp.customer_id
)

select 
    concat(cs.first_name, ' ',cs.last_name) as full_name,
    cs.email, 
    cs.rental_count, 
    cs.total_paid, 
    round(cs.total_paid / cs.rental_count, 2) as average_payment_per_rental
from customer_summary cs;


