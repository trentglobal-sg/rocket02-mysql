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