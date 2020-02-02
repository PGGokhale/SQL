-- SQL Homework : Data Analysis and Visualization BootCamp UT Austin, Batch - Nov 2019- May 2020
USE sakila;
SHOW TABLES;

-- 1a. Display the first and last names of all actors from the table `actor`.
-- 1b. Display the first and last name of each actor in a single column in upper case letters. 
-- Name the column `Actor Name`.

SELECT 
    first_name,
    last_name,
    CONCAT(first_name, ' ', last_name) AS 'Actor Name'
FROM
    actor a;
-- 2a. You need to find the ID number, first name, and last name of an actor, 
-- of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT 
    actor_id, first_name, last_name
FROM
    actor
WHERE
    first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters `GEN`:
SELECT 
    actor_id, first_name, last_name
FROM
    actor
WHERE
    last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. 
-- This time, order the rows by last name and first name, in that order:
SELECT 
    last_name, first_name
FROM
    actor
WHERE
    last_name LIKE '%LI%'
ORDER BY last_name , first_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: 
-- Afghanistan, Bangladesh, and China:
SELECT 
    country_id, country
FROM
    country
WHERE
    country IN ('Afghanistan' , 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. 
-- You don't think you will be performing queries on a description, 
-- so create a column in the table `actor` named `description` and use the 
-- data type `BLOB` (Make sure to research the type `BLOB`, 
-- as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor ADD COLUMN (description BLOB);

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort.
-- Delete the `description` column.
ALTER TABLE actor DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT 
    last_name, COUNT(last_name)
FROM
    actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
SELECT 
    last_name, COUNT(*)
FROM
    actor
GROUP BY last_name
HAVING COUNT(*) >= 2;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as 
-- `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE actor 
SET 
    first_name = 'HARPO'
WHERE
    first_name = 'GROUCHO'
        AND last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. 
-- It turns out that `GROUCHO` was the correct name after all! 
-- In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor 
SET 
    first_name = 'HARPO'
WHERE
    first_name = 'GROUCHO';

--  5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- Extra work! to locate the database where the table 'address' resides.
SELECT 
    `table_schema`
FROM
    `information_schema`.`tables`
WHERE
    `table_name` = 'address';

-- 6a. Use `JOIN` to display the first and last names, as well as the address, 
-- of each staff member. Use the tables `staff` and `address`:
SELECT 
    s.first_name, s.last_name, a.address
FROM
    staff s
        JOIN
    address a ON a.address_id = s.address_id;

SELECT 
    *
FROM
    staff
LIMIT 10;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. 
-- Use tables `staff` and `payment`.
SELECT 
    s.first_name, s.last_name, SUM(p.amount)
FROM
    staff s
        JOIN
    payment p ON s.staff_id = p.staff_id
WHERE
    p.payment_date LIKE '%2005-08-%'
GROUP BY s.first_name , s.last_name;


-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables `film_actor` and `film`. Use inner join.
SELECT 
    f.title, COUNT(fa.actor_id) AS 'Number of Actors'
FROM
    film f
        INNER JOIN
    film_actor fa ON f.film_id = fa.film_id
GROUP BY f.title;

 -- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT 
    f.title, COUNT(i.inventory_id) AS 'Copies'
FROM
    film f
        JOIN
    inventory i ON i.film_id = f.film_id
WHERE
    title = 'Hunchback Impossible';
 
 -- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. 
SELECT 
    c.first_name, c.last_name, SUM(p.amount) AS 'Total Paid'
FROM
    customer c
        JOIN
    payment p ON c.customer_id = p.customer_id
GROUP BY c.last_name;

--  7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
-- films starting with the letters `K` and `Q` have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.

SELECT 
    f.title, l.name
FROM
    film f
        JOIN
    language l ON f.language_id = l.language_id
WHERE
    (l.name = 'English'
        AND (f.title LIKE 'Q%' OR f.title LIKE 'K%'));

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT 
    a.first_name, a.last_name
FROM
    actor a
WHERE
    a.actor_id IN 
    (SELECT fa.actor_id FROM film_actor fa
	 WHERE fa.film_id = 
     (SELECT f.film_id FROM film f WHERE f.title = 'Alone Trip'));

-- 7c. You want to run an email marketing campaign in Canada, 
-- for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
SELECT 
    first_name, last_name, email
FROM
    customer
WHERE
    store_id IN 
    (SELECT store_id 
     FROM store
	 WHERE address_id IN 
		   (SELECT address_id 
            FROM address
			WHERE city_id IN 
				 (SELECT city_id 
                  FROM city
				  WHERE country_id = 
						(SELECT country_id 
                        FROM country
						WHERE country = 'CANADA'))))
ORDER BY first_name , last_name;

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as _family_ films.
SELECT f.title 
FROM film f
WHERE film_id IN 
	  (SELECT film_id 
       FROM film_category
	   WHERE category_id IN 
			 (SELECT category_id 
              FROM category
			  WHERE name = 'family'));

-- * 7e. Display the most frequently rented movies in descending order.
SELECT f2.title, COUNT(r.rental_id) AS 'Number of times rented' 
FROM rental r
JOIN (SELECT i.inventory_id, f.film_id, f.title 
	  FROM inventory i
      JOIN film f 
      WHERE f.film_id = i.film_id) f2
WHERE r.inventory_id = f2.inventory_id
GROUP BY f2.title
ORDER BY COUNT(r.rental_id) DESC;

-- * 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT level2.store_id AS 'store', SUM(p.amount) AS 'Business in $'  
FROM payment p
JOIN (SELECT r.rental_id, level1.store_id 
	  FROM rental r
	  JOIN (SELECT i.inventory_id, i.store_id 
			FROM inventory i
			JOIN store s 
            WHERE i.store_id = s.store_id) level1
	  WHERE level1.inventory_id = r.inventory_id) level2
WHERE level2.rental_id = p.rental_id
GROUP BY level2.store_id;


-- * 7g. Write a query to display for each store its store ID, city, and country.
SELECT level2.store_id, level2.city, co.country 
FROM country co
JOIN(SELECT c.city, c.country_id, level1.store_id 
	 FROM city c
	 JOIN(SELECT a.city_id, s.store_id 
		  FROM address a
		  JOIN store s 
          WHERE a.address_id = s.address_id) level1
	 WHERE level1.city_id = c.city_id) level2
WHERE co.country_id = level2.country_id
GROUP BY level2.store_id;

-- * 7h. List the top five genres in gross revenue in descending order.
-- NOTE: There are five enteries in payment table (corresponding to payment_id 424, 7011, 10840, 14675, 15458)
-- where the rental_id is NULL. Because rental_id is the only way to track the genres these 5 enteries need to be ignored.


SELECT name, Gross_revenue 
FROM (SELECT table4.name, SUM(table4.amount) AS 'Gross_Revenue' 
	 FROM (SELECT c.name, table3.amount, table3.payment_id, table3.inventory_id, table3.film_id, table3.category_id 
	      FROM (SELECT table2.amount, table2.payment_id, table2.inventory_id, table2.film_id, fc.category_id 
				FROM (SELECT table1.amount, table1.payment_id, table1.inventory_id, i.film_id  
					FROM (SELECT p.amount, p.payment_id, r.inventory_id 
						FROM payment p
						LEFT JOIN rental r
                        ON p.rental_id = r.rental_id) table1
					LEFT JOIN inventory i
					ON  table1.inventory_id =i.inventory_id) table2
				LEFT JOIN film_category fc 
                ON table2.film_id = fc.film_id) table3
		LEFT JOIN category c 
        ON table3.category_id = c.category_id) table4
GROUP BY table4.name) AS new_table
ORDER BY Gross_Revenue DESC 
LIMIT 5;


-- * 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.


CREATE VIEW top_genres AS SELECT name, Gross_Revenue 
FROM (SELECT table4.name, SUM(table4.amount) AS 'Gross_Revenue' 
	 FROM (SELECT c.name, table3.amount, table3.payment_id, table3.inventory_id, table3.film_id, table3.category_id 
	      FROM (SELECT table2.amount, table2.payment_id, table2.inventory_id, table2.film_id, fc.category_id 
				FROM (SELECT table1.amount, table1.payment_id, table1.inventory_id, i.film_id  
					FROM (SELECT p.amount, p.payment_id, r.inventory_id 
						FROM payment p
						LEFT JOIN rental r
                        ON p.rental_id = r.rental_id) table1
					LEFT JOIN inventory i
					ON  table1.inventory_id =i.inventory_id) table2
				LEFT JOIN film_category fc 
                ON table2.film_id = fc.film_id) table3
		LEFT JOIN category c 
        ON table3.category_id = c.category_id) table4
GROUP BY table4.name) AS new_table
ORDER BY Gross_Revenue DESC 
LIMIT 5;


-- * 8b. How would you display the view that you created in 8a?
SELECT * FROM top_genres;

-- * 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_genres;

