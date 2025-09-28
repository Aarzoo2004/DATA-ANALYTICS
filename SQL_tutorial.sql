-- SELECT Statement 

SELECT * 
FROM parks_and_recreation.employee_demographics;

SELECT first_name, 
last_name, 
birth_date, 
age, 
(age + 10) * 10 + 10
FROM parks_and_recreation.employee_demographics;
#PEMDAS => Order of operations in mySQL [paranthesis, exponent, multiplication, division, addition, subtraction]

SELECT DISTINCT first_name, gender
FROM parks_and_recreation.employee_demographics;

-- WHERE Statment

SELECT *
FROM employee_salary
WHERE first_name = 'Leslie';

SELECT *
FROM employee_salary
WHERE salary <= 50000;

SELECT *
FROM employee_demographics
WHERE gender != 'Female';

SELECT *
FROM employee_demographics
WHERE birth_date > '1985-01-01';

SELECT *
FROM employee_demographics
WHERE birth_date > '1985-01-01'
OR NOT gender = 'Male';

SELECT *
FROM employee_demographics
WHERE (first_name = 'Leslie' AND age = 44) OR age > 55;

-- LIKE Statement 
-- % (anything) and _ 
SELECT *
FROM employee_demographics
WHERE first_name LIKE '%er%';

SELECT *
FROM employee_demographics
WHERE first_name LIKE 'a___%'; #starts with s and two chars after it and anything after that

SELECT *
FROM employee_demographics
WHERE birth_date LIKE '1989%';

-- GROUP BY Statement

SELECT gender
FROM employee_demographics
GROUP BY gender;

-- Error because if we are not using aggregating functions then the col and group by element should match 
SELECT first_name
FROM employee_demographics
GROUP BY gender;

SELECT gender, AVG(age)
FROM employee_demographics
GROUP BY gender;

-- In output the Office Manager salary is 50k and 60k thats why they have different rows otherwise they would have a single row 
SELECT occupation, salary
FROM employee_salary
GROUP BY occupation, salary;

SELECT gender, AVG(age), MAX(age), MIN(age), COUNT(age)
FROM employee_demographics
GROUP BY gender;

-- ORDER BY (ASC by default)

SELECT *
FROM employee_demographics
ORDER BY gender, age;

SELECT *
FROM employee_demographics
ORDER BY age, gender; # order is important

SELECT *
FROM employee_demographics
ORDER BY 5, 4; # col index

-- HAVING VS WHERE  

-- Error because avg will work when group by is executed but its coming after we are checking the condition
SELECT gender, AVG(age)
FROM employee_demographics
WHERE AVG(age) > 40
GROUP BY gender;

SELECT gender, AVG(age)
FROM employee_demographics
GROUP BY gender
HAVING AVG(age) > 40;

SELECT occupation, AVG(salary)
FROM employee_salary
WHERE occupation LIKE '%manager%' # row level filteration 
GROUP BY occupation
HAVING AVG(salary) > 75000; # aggregate filteration

-- LIMIT

SELECT *
FROM employee_demographics
ORDER BY age DESC
LIMIT 3;

SELECT *
FROM employee_demographics
LIMIT 3, 1; # prints the fourth row

-- ALIASING 

SELECT gender, AVG(age) AS avg_age
FROM employee_demographics
GROUP BY gender
HAVING AVG(age) > 40;

SELECT gender, AVG(age) avg_age
FROM employee_demographics
GROUP BY gender
HAVING AVG(age) > 40;

-- JOINS - for columns

-- INNER JOIN (DEFAULT)

SELECT *
FROM employee_demographics
INNER JOIN employee_salary
	ON employee_demographics.employee_id = employee_salary.employee_id
;

SELECT dem.employee_id, age, occupation
FROM employee_demographics AS dem
INNER JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id
;

-- OUTER JOINS

-- LEFT JOIN - Takes everything from left table

SELECT *
FROM employee_demographics AS dem
LEFT JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id
;

-- RIGHT - Take everything from right table

SELECT *
FROM employee_demographics AS dem
RIGHT JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id
;
  
-- SELF JOIN

SELECT 
emp1.employee_id AS emp_santa, 
emp1.first_name AS first_name_santa,
emp1.last_name AS last_name_santa,
emp2.employee_id AS emp_id, 
emp2.first_name AS first_name_emp,
emp2.last_name AS last_name_emp
FROM employee_salary emp1
JOIN employee_salary emp2
	ON emp1.employee_id + 1 = emp2.employee_id
;

-- JOINING MULTIPLE TABLES TOGETHER

SELECT *
FROM employee_demographics AS dem
INNER JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id
INNER JOIN parks_departments pd
	ON sal.dept_id = pd.department_id
;
 
SELECT * 
FROM parks_departments;

-- UNIONS - for rows

SELECT age, gender
FROM employee_demographics
UNION 
SELECT first_name, last_name
FROM employee_salary
;

SELECT first_name, last_name
FROM employee_demographics
UNION DISTINCT #  distinct by default
SELECT first_name, last_name
FROM employee_salary
;

SELECT first_name, last_name
FROM employee_demographics
UNION ALL # with duplicates
SELECT first_name, last_name
FROM employee_salary
;

SELECT first_name, last_name, 'Old Male' AS label
FROM employee_demographics
WHERE age > 40 AND gender = 'Male'
UNION
SELECT first_name, last_name, 'Old Female' AS label
FROM employee_demographics
WHERE age > 40 AND gender = 'Female'
UNION
SELECT first_name, last_name, 'Highly Paid Employee' AS label
FROM employee_salary
WHERE salary > 70000
ORDER BY first_name, last_name
;

-- STRING FUNCTIONS

SELECT LENGTH('skyfall');

SELECT first_name, LENGTH(first_name)
FROM employee_demographics
ORDER BY 2;

SELECT UPPER('sky');
SELECT LOWER('sky');

SELECT first_name, UPPER(first_name)
FROM employee_demographics;

SELECT TRIM('			sky			');
SELECT LTRIM('			sky			');
SELECT RTRIM('			sky			');

SELECT first_name, 
LEFT(first_name, 4), # 4 chars from left of the first_name
RIGHT(first_name, 4), # 4 chars from right of the first_name
SUBSTRING(first_name, 3, 2), # start with third pos and then two chars
birth_date,
SUBSTRING(birth_date, 6, 2) AS birth_month
FROM employee_demographics;

SELECT first_name, REPLACE(first_name, 'a', 'z') # replace a with z
FROM employee_demographics;

SELECT LOCATE('x', 'Alexander'); # returns pos of x in string

SELECT first_name, LOCATE('An', first_name)
FROM employee_demographics;

SELECT first_name, last_name,
CONCAT(first_name, ' ', last_name) AS full_name
FROM employee_demographics;

-- CASE STATEMENTS

SELECT first_name,
last_name,
age,
CASE
	WHEN age <= 30 THEN 'Young'
    WHEN age BETWEEN 31 AND 50 THEN 'Old'
    WHEN age >= 50 THEN "On Death's Door"
END AS Age_Bracket
FROM employee_demographics;

-- Pay Increase and Bonus
-- < 50000 = 5%
-- > 50000 = 7%
-- Finance = 10% Bonus

SELECT first_name, last_name, salary,
CASE
	WHEN salary < 50000 THEN salary * 1.05
    WHEN salary > 50000 THEN salary * 1.07
END AS New_Salary,
CASE
	WHEN dept_id = 6 THEN salary * .10
END AS Bonus
FROM employee_salary;

-- SUBQUERIES

SELECT * 
FROM employee_demographics
WHERE employee_id IN # IN is the operator
	(-- subquery, it is the operand and it should return only one col
		SELECT employee_id
			FROM employee_salary
            WHERE dept_id = 1);

-- incorrect version 
SELECT first_name, salary, AVG(salary)
FROM employee_salary
GROUP BY first_name, salary;

-- fixed 
SELECT first_name, salary,
(
	SELECT AVG(salary)
    FROM employee_salary
)
FROM employee_salary;

SELECT gender, AVG(age), MAX(age), MIN(age), COUNT(age)
FROM employee_demographics
GROUP BY gender;

SELECT gender, AVG(`MAX(age)`)
FROM 
(
	SELECT gender, AVG(age), MAX(age), MIN(age), COUNT(age)
		FROM employee_demographics
		GROUP BY gender
) AS Agg_table # Alias is mandatory
GROUP BY gender; # GROUP BY gender tells SQL: “For each gender, take the MAX(age) values and compute their average.”

SELECT AVG(avg_age)
FROM 
(
	SELECT gender, 
		AVG(age) AS avg_age, 
        MAX(age) AS max_age, 
        MIN(age) AS min_age, 
        COUNT(age)
		FROM employee_demographics
		GROUP BY gender
) AS Agg_table # Alias is mandatory
;

-- WINDOW FUNCTIONS

SELECT gender, AVG(salary) AS avg_salary
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
GROUP BY gender; 

SELECT gender, AVG(salary) OVER()
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id; 

SELECT dem.first_name, dem.last_name, gender, AVG(salary) OVER(PARTITION BY gender)
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id;

SELECT dem.first_name, dem.last_name, gender, AVG(salary) AS avg_salary
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
GROUP BY dem.first_name, dem.last_name, gender; 

SELECT dem.first_name, dem.last_name, gender, 
SUM(salary) OVER(PARTITION BY gender)
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id;
    
SELECT dem.employee_id, dem.first_name, dem.last_name, gender, salary,
SUM(salary) OVER(PARTITION BY gender ORDER BY dem.employee_id) AS Rolling_Total
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id;
    
# ROW_NUMBER() gives each row a unique number within identical-value groups, so the first occurrence is 1 and duplicates get 2, 3, ….
SELECT *,
ROW_NUMBER() OVER()
FROM employee_demographics;

SELECT dem.employee_id, dem.first_name, dem.last_name, gender, salary,
ROW_NUMBER() OVER()
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id;
    
SELECT dem.employee_id, dem.first_name, dem.last_name, gender, salary,
ROW_NUMBER() OVER(PARTITION BY gender)
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id;

SELECT dem.employee_id, dem.first_name, dem.last_name, gender, salary,
ROW_NUMBER() OVER(PARTITION BY gender ORDER BY salary DESC) AS row_num,
RANK() OVER(PARTITION BY gender ORDER BY salary DESC) AS rank_num, # the next number is not numerically but positionally (look at last three)
DENSE_RANK() OVER(PARTITION BY gender ORDER BY salary DESC) AS rank_num # next number is numerically 
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id;

-- COMMON TABLE EXPRESSION (CTE)
-- they are unique and can be used immediately after creation 

WITH CTE_Example (gender, avg_sal, max_sal, min_sal, count_Sal) AS
(
SELECT gender, AVG(age), MAX(salary), MIN(salary), COUNT(salary)
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
GROUP BY gender
)
SELECT AVG(avg_sal)
FROM CTE_Example
;
 
-- Error because its just temporary creation and not saved anywhere 
SELECT AVG(avg_sal)
FROM CTE_Example;

-- same job as above with subquery  
SELECT AVG(avg_sal)
FROM 
(
SELECT gender, AVG(age) avg_sal, MAX(salary) max_age, MIN(salary) min_age, COUNT(salary) count_sal
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
GROUP BY gender
) example_subquery;

WITH CTE_Example AS
(
SELECT employee_id, gender, birth_date
FROM employee_demographics 
WHERE birth_date > '1985-01-01'
),
CTE_Example2 AS
(
SELECT employee_id, salary
FROM employee_salary
WHERE salary > 50000
)
SELECT *
FROM CTE_Example
JOIN CTE_Example2
	ON CTE_Example.employee_id = CTE_Example2.employee_id
;

-- TEMPORARY TABLES (only visible in the session they arey created in)

CREATE TEMPORARY TABLE temp_table
(
first_name VARCHAR(50),
last_name VARCHAR(50),
favorite_movie VARCHAR(100)
);

SELECT * 
FROM temp_table;

INSERT INTO temp_table
VALUES('Aarzoo', 'Asar', 'Marvels');

SELECT *
FROM employee_salary;

CREATE TEMPORARY TABLE salary_over_50k
SELECT * 
FROM employee_salary
WHERE salary >= 50000;

SELECT *
FROM salary_over_50k;

-- STORED PROCEDURES

CREATE PROCEDURE large_salaries()
SELECT *
FROM employee_salary
WHERE salary >= 50000;

CALL large_salaries();

# now the end of the procedure is defined by the $ not ;
DELIMITER  $$ 
CREATE PROCEDURE large_salaries2()
BEGIN
	SELECT *
	FROM employee_salary
	WHERE salary >= 50000;
	SELECT *
	FROM employee_salary
	WHERE salary >= 10000;
END $$
DELIMITER ;

CALL large_salaries2();

-- paramters 
DELIMITER  $$ 
CREATE PROCEDURE large_salaries3(emp_id_param INT)
BEGIN
	SELECT salary
	FROM employee_salary
	WHERE employee_id = emp_id_param;
END $$
DELIMITER ;

CALL large_salaries3(1);

-- TRIGGERS
# AFTER/BEFORE
# NEW - only new inserted row values
# OLD - for rows deleted or updated

DELIMITER $$
CREATE TRIGGER employee_insert
	AFTER INSERT ON employee_salary
    FOR EACH ROW 
BEGIN
	INSERT INTO employee_demographics (employee_id, first_name, last_name)
    VALUES (NEW.employee_id, NEW.first_name, NEW.last_name);
END $$
DELIMITER ;

INSERT INTO employee_salary (employee_id, first_name, last_name, occupation, salary, dept_id)
VALUES (13, 'Jawad', 'Khan', 'Entertainment 720 CEO', 1000000, NULL);

SELECT * 
FROM employee_salary;

SELECT * 
FROM employee_demographics;

-- EVENTS
# A trigger happens when an event takes place
# An event happens when it's scheduled

SELECT * 
FROM employee_demographics;

DROP EVENT IF EXISTS delete_retirees;

DELIMITER $$
CREATE EVENT delete_retirees2
ON SCHEDULE EVERY 30 SECOND
DO 
BEGIN
	DELETE 
	FROM employee_demographics
    WHERE age >= 60; 
END $$
DELIMITER ;

SELECT * 
FROM employee_demographics;

SHOW VARIABLES LIKE 'event%';

