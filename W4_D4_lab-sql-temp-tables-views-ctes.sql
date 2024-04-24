# Step 1: Create a View
# First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count)
CREATE VIEW summary_rental_info_for_customer AS
SELECT c.customer_id, c.first_name, c.last_name, c.email, COUNT(r.rental_id) AS rental_count
FROM customer AS c
INNER JOIN rental AS r
USING (customer_id)
GROUP BY customer_id, c.first_name, c.last_name, c.email
ORDER BY rental_count DESC;


# Step 2: Create a Temporary Table
# Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer
CREATE TEMPORARY TABLE total_paid_by_customer AS
SELECT c.customer_id, c.first_name, SUM(p.amount) AS amount_paid
FROM summary_rental_info_for_customer AS sr
INNER JOIN payment AS p
USING (customer_id) 
GROUP BY sr.customer_id
ORDER BY amount_paid DESC;

SELECT *
FROM total_paid_by_customer;


# Step 3: Create a CTE and the Customer Summary Report
# Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid
WITH customer_summary_report AS (
SELECT sr.customer_id, sr.first_name, sr.last_name, sr.email, sr.rental_count AS rental_count, SUM(tp.amount_paid) AS total_amount_paid
FROM summary_rental_info_for_customer AS sr
INNER JOIN total_paid_by_customer AS tp
USING (customer_id)
GROUP BY sr.customer_id, sr.first_name, sr.last_name, sr.email, sr.rental_count
)
SELECT *
FROM customer_summary_report
ORDER BY total_amount_paid DESC;


# Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count (Note to self: you must reference the CTE again) 
WITH customer_summary_report AS (
SELECT sr.customer_id, sr.first_name, sr.last_name, sr.email, sr.rental_count AS rental_count, SUM(tp.amount_paid) AS total_amount_paid
FROM summary_rental_info_for_customer AS sr
INNER JOIN total_paid_by_customer AS tp
USING (customer_id)
GROUP BY sr.customer_id, sr.first_name, sr.last_name, sr.email, sr.rental_count
)
SELECT first_name, last_name, email, rental_count, total_amount_paid, total_amount_paid/rental_count AS average_payment_per_rental
FROM customer_summary_report
ORDER BY total_amount_paid DESC;