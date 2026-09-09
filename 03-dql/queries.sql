-- SELECT * => all columns
-- select all columns from employees (all the rows are implied)
SELECT * FROM employees;

-- SELECT some columns
SELECT firstName, lastName FROM employees;

-- SELECT columns as alias
select firstName as "First Name", lastName as "Last Name", email as "Email" from employees;

-- FILTERING BY ROWS
-- select all employees from office code 1
select * from employees WHERE officeCode = 1;

-- select all employees who are sales rep
select * from employees where jobTitle = "Sales Rep";

-- find the first name, last name, email of all from office code 1
select firstName, lastName email from employees
    where officeCode = 1;

-- finding by comparison operators
SELECT * FROM customers WHERE creditLimit >= 50000;

-- Finding by string patterns
-- find all employees whose job title includes the word "sales"
-- using LIKE with string patterns will ignore case
SELECT * FROM employees WHERE jobTitle LIKE "%sales%";

-- find all payments above 5000
SELECT * FROM payments WHERE amount >= 5000;

-- find all orders that mentioned fedex
SELECT * FROM orders WHERE comments LIKE "%fedex%";

-- Comparison operators >, <, >=, <=, ==, <>

-- Logical operators - and / or

-- Find all sales rep from office code = 1
SELECT * FROM employees WHERE officeCode = 1 AND jobTitle = "Sales Rep";

-- Find all customers from USA with at least 5K credit limit
SELECT * FROM customers WHERE country = "USA" AND creditLimit > 5000;

-- Select all employees from office code 1 or office code 2
SELECT * FROM employees WHERE officeCode =1 OR officeCode = 2;

-- find all orders which has been cancelled or in process
SELECT * FROM orders WHERE status = "cancelled" or status = "in process";

-- find all sales rep from office code 1 or office code 2
select * from employees where jobTitle = "sales rep" and (officeCode = 2 or officeCode = 1);

-- what are the different possible status an order can be in?
-- show all the possible distinct values for the provided column
SELECT DISTINCT(status) FROM orders;

-- sorting
-- by default it's in ascending order (low to high)
SELECT * FROM customers ORDER BY creditLimit;

-- show all customers by their credit limit from the highest to lowest
SELECT * FROM customers ORDER BY creditLimit DESC;

-- show the top 5 payment by customer number 141
SELECT * FROM payments
 WHERE customerNumber = 141 
 ORDER BY amount DESC
 LIMIT 5;

 SELECT * FROM payments
 WHERE customerNumber = 141 
 ORDER BY paymentDate DESC, amount DESC;

 -- find the top 5 customers in USA with the best credit limit
SELECT * FROM customers WHERE country="USA" order by creditLimit DESC LIMIT 5;

-- JOIN allows us to temporary create a copy of two tables joined together
-- by their FK to PK
-- JOIN will always happen first
-- WHERE will happen on the joined table
-- SELECT * will also happen on the joined table
SELECT firstName, lastName, email, offices.officeCode, addressLine1, addressLine2 FROM employees JOIN offices
	ON employees.officeCode = offices.officeCode
WHERE jobTitle = "Sales Rep"

-- alternative way using alias
SELECT e.firstName, e.lastName, e.email, o.officeCode, o.addressLine1, o.addressLine2 
  FROM employees AS e JOIN offices AS o
	ON e.officeCode = o.officeCode
WHERE jobTitle = "Sales Rep"

-- Find all customers whose sales rep are from officeCode 1
-- with credit limit more than 50K
-- then only list the top ten
SELECT * FROM customers JOIN employees
  ON customers.salesRepEmployeeNumber = employees.employeeNumber
  WHERE officeCode = 1 AND creditLimit >= 50000
  ORDER BY creditLimit DESC
  LIMIT 10;
  
-- Now only from offices in the USA
SELECT * FROM customers JOIN employees
 	 ON customers.salesRepEmployeeNumber = employees.employeeNumber
  JOIN offices
     ON employees.officeCode = offices.officeCode
  WHERE creditLimit >= 50000 AND offices.country="USA"
  ORDER BY creditLimit DESC
  LIMIT 10;

-- inner join
-- for a row on the LHS of the join to appear in the result table,
-- they must find a partner row in the RHS of the join
-- the inner join is the also the default join
SELECT count(*) from customers INNER JOIN employees
  ON customers.salesRepEmployeeNumber = employees.employeeNumber;


-- find all the customers and their sales rep
-- EVEN if they do not have have a sales rep
-- left join means all the rows from the LHS of the join
-- will be the results, regardless if they have a match with
-- the RHS table
SELECT * from customers LEFT JOIN employees
  ON customers.salesRepEmployeeNumber = employees.employeeNumber;

-- FULL OUTRE JOIN both rows from both tables are always included
-- but not supported by MySQL

-- Get the current date on the server
SELECT CURDATE()

-- Get the current date and time on the server
SELECT NOW();

-- get all the payments from the year 2003 onwards
select * from payments where paymentDate >= "2003-01-01"

-- get all the payments in 2003 ONLY
select * from payments where paymentDate >= "2003-01-01" AND paymentDate <="2003-12-31"
-- get all payments in 2003 ONLY (using between)
elect * from payments where paymentDate between "2003-01-01" AND "2003-12-31";

-- extract date components using YEAR, DAY and MONTH
select * from payments WHERE YEAR(paymentDate) = 2003 AND MONTH(paymentDate) = 6;

-- find all shipment that are late
select * from orders where shippedDate > requiredDate;

-- find all shipment that are late
select * from orders where shippedDate - requiredDate > 3;

-- find all shipment that are late and are never shipped
select * from orders where shippedDate - requiredDate > 3 OR shippedDate is null;

-- COUNT - count how many rows
-- SUM(col) - sum up the col
-- AVG(col) - average up the col
-- MIN(col) - the minmal value
-- MAX(col) - the maximal value

-- show how many employees are there in each office
select officeCode, count(*) AS "employeeCount" from employees
group by officeCode;

-- the sum of all payments by each customer
-- 1. which table
-- 2. group by what?
-- 3. select what
select customerNumber, sum(amount) from payments
group by customerNumber;

-- find the sum of all payments by each customer
-- and only show the customer who has paid more than 100K
-- having allows us to filter the groups
select customerNumber, sum(amount) from payments
group by customerNumber
having sum(amount) > 100000;


-- find the top 5 best sales rep from USA by the amount of payment made by their customers
-- in the year 2003

-- step 1: identify the tabless and join them
select salesRepEmployeeNumber,  sum(amount) as "total" from employees 
	join offices
		on employees.officeCode = offices.officeCode
	join customers
		on employees.employeeNumber = customers.salesRepEmployeeNumber
	join payments
		on customers.customerNumber = payments.customerNumber
where year(paymentDate) = '2003' AND offices.country = 'USA'
group by salesRepEmployeeNumber
having total > 200000
order by total desc
limit 5;

-- order of precedence
-- 1. FROM and JOIN
-- 2. WHERE will filter the join tables
-- 3. GROUP BY will break the tables in groups
-- 4. SELECT and alias (aka renaming the columns)
-- 5. HAVING
-- 6. ORDER BY
-- 7. LIMIT
-- 8. (not shown) OFFSET

-- IMPORTANT: for mysql v8 onwards, whatever we select, we must select by group by
-- find the top 5 best sales rep from USA by the amount of payment made by their customers
-- in the year 2003

-- step 1: identify the tabless and join them
select salesRepEmployeeNumber, firstName, lastName,  sum(amount) as "total" from employees 
	join offices
		on employees.officeCode = offices.officeCode
	join customers
		on employees.employeeNumber = customers.salesRepEmployeeNumber
	join payments
		on customers.customerNumber = payments.customerNumber
where year(paymentDate) = '2003' AND offices.country = 'USA'
group by salesRepEmployeeNumber, firstName, lastName
having total > 200000
order by total desc
limit 5;

-- Homework
-- 1. show how many customers there are for each country, and their average credit limit
-- 1b. and also the average amount of payment they have made, but only in from June 2022 to June 2023 (inclusive)
-- 1c. and only if they have made at least 50K in payment

