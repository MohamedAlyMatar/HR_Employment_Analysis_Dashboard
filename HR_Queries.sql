use hr_data;
SELECT * FROM hr;

ALTER table hr
change column ï»¿id emp_id varchar(20) NULL;

describe hr;
SELECT birthdate FROM hr;

SET sql_safe_updates = 0;

UPDATE hr
SET hire_date = CASE
WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
ELSE NULL
END;

UPDATE hr
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != '';

UPDATE hr
SET termdate = '0000-00-00'
WHERE termdate IS NULL OR termdate = '' OR STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC') IS NULL;

-- UPDATE existing data
UPDATE hr
SET termdate = NULL
WHERE termdate = '0000-00-00' OR termdate = ''; -- SET invalid/empty dates to NULL

-- Modify column data type
ALTER TABLE hr
MODIFY COLUMN termdate DATE;

SELECT termdate FROM hr;

ALTER table hr
add column age int;

SELECT * FROM hr;

UPDATE hr
SET age = timestampdiff(YEAR,birthdate,CURDATE());

SELECT
min(age) AS youngest,
max(age) AS oldest
FROM hr;

SELECT
count(*) FROM hr WHERE age <18;

-- QUESTIONS

-- 1. What is the gender breakdown of employees in the company?
SELECT gender, count(*) AS count
FROM hr
WHERE age >= 18 or termdate = null
GROUP BY gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?
SELECT race, count(*) AS count
FROM hr
WHERE age >= 18 or termdate = null
GROUP BY race 
ORDER BY count(*) desc;

-- 3. What is the age distribution of employees in the company?
SELECT
min(age) AS youngest,
max(age) AS oldest
FROM hr
WHERE age > 0;

SELECT
case
WHEN age >= 18 AND age <=24 THEN '18-24'
WHEN age >= 25 AND age <=34 THEN '25-34'
WHEN age >= 35 AND age <=44 THEN '35-44'
WHEN age >= 45 AND age <=54 THEN '44-54'
WHEN age >= 55 AND age <=64 THEN '55-64'
else '65+'
end AS age_group, gender,
count(*) AS count
FROM hr
WHERE age > 0
GROUP BY age_group, gender
ORDER BY age_group, gender;

-- 4. How many employees work at headquarters versus remote locations?
SELECT location, count(*) AS count
FROM hr
WHERE age > 0
GROUP BY location;

-- 5. What is the average length of employment for employees who have been terminated?
SELECT 
round(avg(datediff(termdate, hire_date))/365,0) AS avg_length_employment
FROM hr
WHERE termdate <= curdate() and age > 0;

-- 6. How does the gender distribution vary across departments and job titles?
SELECT gender, department, count(*) AS count
FROM hr
WHERE age > 0 
GROUP BY department, gender
ORDER BY department;

-- 7. What is the distribution of job titles across the company?
SELECT jobtitle, count(*) AS count
FROM hr
WHERE age > 0
GROUP BY jobtitle
ORDER BY jobtitle desc;

-- 8. Which department has the highest turnover rate?
SELECT
department, total_count, terminated_count, terminated_count/total_count AS termination_rate
FROM(
SELECT department,
count(*) AS total_count,
sum(case when termdate <= curdate() then 1 else 0 end) AS terminated_count
FROM hr
WHERE age >= 18
GROUP BY department
) AS subquery
ORDER BY termination_rate desc;

-- 9. What is the distribution of employees across locations by city and state?
SELECT location_state, count(*) AS count
FROM hr
WHERE age > 0
GROUP BY location_state
ORDER BY count desc;

-- 10. How has the company's employee count changed over time based ON hire and term dates?
SELECT 
year, 
hires, 
terminations, 
hires - terminations AS net_changes,
round((hires - terminations)/hires*100,2) AS net_changes_percentage
FROM(SELECT
year(hire_date) AS year,
count(*) AS hires,
sum(case when termdate <= curdate() then 1 else 0 end) AS terminations
FROM hr
WHERE age > 0
GROUP BY year(hire_date)
) AS subquery
ORDER BY year asc;

-- 11. What is the tenure distribution for each department?
SELECT department, round(avg(datediff(termdate, hire_date)/365),0) AS avg_tenure
FROM hr
WHERE termdate <= curdate() AND age >= 18
GROUP BY department;
