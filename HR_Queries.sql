use hr_data;
select * from hr;

alter table hr
change column ï»¿id emp_id varchar(20) NULL;

describe hr;
select birthdate from hr;

set sql_safe_updates = 0;

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

-- Update existing data
UPDATE hr
SET termdate = NULL
WHERE termdate = '0000-00-00' OR termdate = ''; -- Set invalid/empty dates to NULL

-- Modify column data type
ALTER TABLE hr
MODIFY COLUMN termdate DATE;

select termdate from hr;

alter table hr
add column age int;

select * from hr;

update hr
set age = timestampdiff(YEAR,birthdate,CURDATE());

select
min(age) as youngest,
max(age) as oldest
from hr;

select
count(*) from hr where age <18;

-- QUESTIONS

-- 1. What is the gender breakdown of employees in the company?
select gender, count(*) as count
from hr
where age >= 18 or termdate = null
group by gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?
select race, count(*) as count
from hr
where age >= 18 or termdate = null
group by race 
order by count(*) desc;

-- 3. What is the age distribution of employees in the company?
select
min(age) as youngest,
max(age) as oldest
from hr
where age > 0;

select
case
WHEN age >= 18 AND age <=24 THEN '18-24'
WHEN age >= 25 AND age <=34 THEN '25-34'
WHEN age >= 35 AND age <=44 THEN '35-44'
WHEN age >= 45 AND age <=54 THEN '44-54'
WHEN age >= 55 AND age <=64 THEN '55-64'
else '65+'
end as age_group, gender,
count(*) as count
from hr
where age > 0
group by age_group, gender
order by age_group, gender;

-- 4. How many employees work at headquarters versus remote locations?
select location, count(*) as count
from hr
where age > 0
group by location;

-- 5. What is the average length of employment for employees who have been terminated?
select 
round(avg(datediff(termdate, hire_date))/365,0) as avg_length_employment
from hr
where termdate <= curdate() and age > 0;

-- 6. How does the gender distribution vary across departments and job titles?
select gender, department, count(*) as count
from hr
where age > 0 
group by department, gender
order by department;

-- 7. What is the distribution of job titles across the company?
select jobtitle, count(*) as count
from hr
where age > 0
group by jobtitle
order by jobtitle desc;

-- 8. Which department has the highest turnover rate?
select
department, total_count, terminated_count, terminated_count/total_count as termination_rate
from(
select department,
count(*) as total_count,
sum(case when termdate <= curdate() then 1 else 0 end) as terminated_count
from hr
where age >= 18
group by department
) as subquery
order by termination_rate desc;

-- 9. What is the distribution of employees across locations by city and state?
select location_state, count(*) as count
from hr
where age > 0
group by location_state
order by count desc;

-- 10. How has the company's employee count changed over time based on hire and term dates?
select 
year, 
hires, 
terminations, 
hires - terminations as net_changes,
round((hires - terminations)/hires*100,2) as net_changes_percentage
from(select
year(hire_date) as year,
count(*) as hires,
sum(case when termdate <= curdate() then 1 else 0 end) as terminations
from hr
where age > 0
group by year(hire_date)
) as subquery
order by year asc;

-- 11. What is the tenure distribution for each department?
SELECT department, round(avg(datediff(termdate, hire_date)/365),0) AS avg_tenure
FROM hr
WHERE termdate <= curdate() AND age >= 18
GROUP BY department;
