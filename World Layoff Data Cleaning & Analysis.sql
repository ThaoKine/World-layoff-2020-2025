-- Data Cleaning & Analysis Layoffs (2020 - 2025)
-- step 1: create a new database (watch Alex the Analyst: https://www.youtube.com/watch?v=OT1RErkfLNQ&t=9766s)
-- step 2: make a copy of the raw data as a backup

-- make a copy of table:
create table present_layoffs_copy
like `layoffs(2021-2025)`;

-- fill out the data:
insert present_layoffs_copy
select *
from `layoffs(2021-2025)`;

-- step 3: remove duplicates (if any) -- Should NOT use CTE because CTE can not be update/delete in Mysql
-- add another column as row_num and fill the data
alter table present_layoffs_copy
add column row_num INT;
-- if the row_num > 1, => there are duplicates
update present_layoffs_copy as main
join (
	select company,
		row_number () over (
partition by company, location, total_laid_off, `date`, percentage_laid_off, industry, stage, funds_raised, country) as row_num
from present_layoffs_copy
	) as sub
on main.company = sub.company
set main.row_num = sub.row_num;

delete -- delete duplicates
from present_layoffs_copy
where row_num > 1 ;

alter table present_layoffs_copy -- drop column row_num since it's innecessary now
drop column row_num;

-- step 4: standardize the data

Alter table present_layoffs_copy
add column Tag varchar (255)
;

update present_layoffs_copy
set Tag = case 
		when Right (location, 8) = 'Non-U.S.'
		then 'Non-U.S.'
		else 'U.S'
		end;

UPDATE present_layoffs_copy
SET location = TRIM(TRAILING ',Non-U.S.' FROM location)
WHERE RIGHT(location, 9) = ',Non-U.S.';

UPDATE present_layoffs_copy
SET location = TRIM(TRAILING ',' FROM location)
WHERE RIGHT(location, 1) = ',';

-- chage date (string to date) 
update present_layoffs_copy
set `date` = str_to_date(`date`, '%m/%d/%Y');

alter table present_layoffs_copy
modify column `date` date;

-- chage percentage_laid_off (text to decimal) 
-- Note: you should add a new column instead of change the original column's data type
-- BECAUSE if your original column will be the backup, and you can compare if the new column
-- has the same data or not

alter table present_layoffs_copy
add column laid_off_percent Decimal (5,2);

update present_layoffs_copy
set laid_off_percent = cast(replace(percentage_laid_off, '%', '') as DECIMAL(5,2))/100
WHERE percentage_laid_off REGEXP '^[0-9]+%$'; -- only applies to clean, valid rows

select percentage_laid_off, laid_off_percent
from present_layoffs_copy
;
alter table present_layoffs_copy
drop column percentage_laid_off;


alter table present_layoffs_copy
add column funds_raised_million_Decimal Decimal (10,2);
select *
from present_layoffs_copy;

update present_layoffs_copy
set funds_raised_million_Decimal = cast(replace(funds_raised_million, '$', '') as DECIMAL(10,2))
WHERE TRIM(REPLACE(funds_raised_million, '$', '')) REGEXP '^[0-9]+(\.[0-9]+)?$';

select funds_raised_million, funds_raised_million_Decimal -- check the values again
from present_layoffs_copy
;
alter table present_layoffs_copy
drop column funds_raised_million;

alter table present_layoffs_copy
rename column funds_raised_million_Decimal to funds_raised_million;
-- step 4: Look into null/blank values, we might need to remove them(populate null value = fill the null values with real data)
select *
from present_layoffs_copy
where total_laid_off is null or total_laid_off = ' '
or laid_off_percent is null or laid_off_percent = ' '; 
-- after looking into them, we see that only laid_off_percent is null but total_laid_off has complete valid values. => no need to remove rows has null.

-- Blank values of funds_raised:
ALTER TABLE present_layoffs_copy
RENAME COLUMN funds_raised TO funds_raised_million;

select *
from present_layoffs_copy
where funds_raised_million = '';

update present_layoffs_copy
set funds_raised_million = '$3800'
where company = 'Playtika' and `date` ='2025-06-05'
;

update present_layoffs_copy
set funds_raised_million = '$2200'
where company = 'Playtika' and `date` ='2022-12-09'
;

update present_layoffs_copy
set funds_raised_million = '$20.18'
where company = 'Beam'
;

update present_layoffs_copy
set funds_raised_million = '$1300'
where company = 'NetApp'
;

update present_layoffs_copy
set funds_raised_million = '$120' -- Acquisition price by Armis: 120M but funding raised before acquisition is 50M
where company = 'Otorio'
;

update present_layoffs_copy
set country = 'Ireland' 
where company = 'Tiktok' and location ='Dublin';

update present_layoffs_copy
set country = 'United States' 
where company = 'Tiktok' and location ='Los Angeles';

select * from present_layoffs_copy;

update present_layoffs_copy
set stage = 'Subsidiary'
where company = 'Tiktok';

update present_layoffs_copy
set funds_raised_million =  '165.4'
where company = 'Better Collective' and `date` = '2024-11-14';

update present_layoffs_copy
set funds_raised_million =  '$875'
where company = 'ShareFile' and `date` ='2024-11-07';

update present_layoffs_copy
set funds_raised_million = '$940'
where company = 'Aakash' and `date` ='2024-09-18';

update present_layoffs_copy
set funds_raised_million = '$50'
where company = 'PrepLadder' and `date` ='2024-05-08';

update present_layoffs_copy
set funds_raised_million = '$2350'
where company = 'Assurance' and `date`='2024-05-01';

update present_layoffs_copy
set funds_raised_million = '$3400'
where company = 'Orbotech' and `date` = '2024-03-19';

update present_layoffs_copy
set funds_raised_million = '$35'
where company = 'Project Ronin' and `date` ='2024-03-01';

update present_layoffs_copy
set funds_raised_million = '$2.31'
where company = 'Sirplus' and `date` ='2024-01-17';

update present_layoffs_copy
set funds_raised_million = '$297'
where company = 'Tidal' and `date` ='2023-12-06';

update present_layoffs_copy
set funds_raised_million = '$115'
where company = 'SeekOut' and `date` ='2023-10-05';

update present_layoffs_copy
set funds_raised_million = '$70'
where company = 'Rivos' and `date` ='2023-08-23';

update present_layoffs_copy
set funds_raised_million = '$1.8'
where company = 'CodeClan' and `date` ='2023-08-04';

update present_layoffs_copy
set funds_raised_million = '$90'
where company = 'Amdocs' and `date` ='2023-07-06';

update present_layoffs_copy
set funds_raised_million = '$61'
where company = 'Payoneer' and `date` ='2023-06-26';

update present_layoffs_copy
set funds_raised_million = '$28300'
where company = 'Cerner' and `date` ='2023-05-16';

update present_layoffs_copy
set funds_raised_million = '$111'
where company = 'Momentis Surgical' and `date` ='2023-05-08';

update present_layoffs_copy
set funds_raised_million = '$34000'
where company = 'Red Hat' and `date` ='2023-04-24';

update present_layoffs_copy
set funds_raised_million = '$1.3'
where company = 'Avocargo' and `date` ='2023-04-06';

update present_layoffs_copy
set funds_raised_million = '$20'
where company = '1K Kirana' and `date` ='2023-04-04';

update present_layoffs_copy
set funds_raised_million = '$3600'
where company = 'Hyland Software';

update present_layoffs_copy
set funds_raised_million = '$628'
where company = 'Bolt';

update present_layoffs_copy
set funds_raised_million = '$663'
where company = 'CommerceHub';

update present_layoffs_copy
set funds_raised_million = '$150'
where company = 'Genesis' and `date` ='2023-01-05';

update present_layoffs_copy
set funds_raised_million = '$30'
where company = 'Hirect';

update present_layoffs_copy
set funds_raised_million = '$125'
where company = 'Productboard';

update present_layoffs_copy
set funds_raised_million = '$140'
where company = 'GoFundMe';

update present_layoffs_copy
set funds_raised_million = '$200'
where company = 'Genesis' and `date` ='2022-08-17';

update present_layoffs_copy
set funds_raised_million = '$50'
where company = 'Article' and `date` ='	2022-08-04';

update present_layoffs_copy
set funds_raised_million = '$60'
where company = 'Callisto Media' and `date` ='2022-07-21';

-- step 5: remove unecessary columns or rows (be careful): from step 4, we don't identify any unecessary columns or rows => no need to remove them

#########################################################

-- NEXT, EXPLORATORY DATA ANALYSIS
-- “Looking at your data closely and curiously to understand what’s in it.”

-- It’s like being a detective — trying to:
## See patterns
## Spot weird or missing things
## Ask: “What’s going on here?”

-- Business question: Are certain industries (e.g., tech, healthcare, finance) more prone to layoffs?
-- Smaller question: how to measure 'proneness'? i.e, how can we know that certain industries are prone to layoffs?
-- I choose merit for proneness: 

-- 1. total layoffs events per industry, 
Select 
	industry,
    Count(*) as number_layoff_events_industry,
    Sum(total_laid_off) as total_people_laid_off
from present_layoffs_copy
Group by industry
order by total_people_laid_off Desc;

-- 2. Average percentage laid off by industry
Update present_layoffs_copy
set industry = 'Other'
where company = 'Appsmith';

select 
	industry,
    round(avg(laid_off_percent),2) as average_laid_off_percent
from present_layoffs_copy
where laid_off_percent is not null
group by industry
order by average_laid_off_percent Desc;

-- Business question: Does startup stage affect layoffs? 
-- Merit: total layoffs by stage, Average layoff size (numbers) by stage

-- 1. total layoffs by stage
update present_layoffs_copy
set stage = 'Subsidiary'
where company = 'Verily' -- I search Google to fill in the blank
;

update present_layoffs_copy
set stage = 'Subsidiary'
where company = 'Relevel' -- I search Google to fill in the blank
;

update present_layoffs_copy
set stage = 'Subsidiary'
where company = 'Advata' -- I search Google to fill in the blank
;

select 
	stage,
    Count(*) as number_layoff_events_stage,
    Sum(total_laid_off) as total_people_laid_off_stage
from present_layoffs_copy
Group by stage
order by total_people_laid_off_stage Desc;

-- Average layoff size by stage = average people laid off by stage

select stage,
	round(avg(total_laid_off),2) as avg_layoff_size
from present_layoffs_copy
group by stage
order by avg_layoff_size desc;

-- Is there a relationship between funding and layoffs?
-- Stakeholders often wonder: “If a company raised a lot of money, why would it still lay off employees?”

-- So I want to use different funding brackets to identify underfunding, overfunding. After using quadtifiles in Excel (because I don't know How to use it in MySQL :>>), I have these funding tiers:
-- Funding Range	Explanation
-- Under 60M	    Below Q1 – small / seed funding
-- 60M–190M	        Q1–Q2 – early/Series A funding
-- 190M–535M		Q2–Q3 – Series B–C / growth stage
-- 535M–1B			Q3 to just below extreme outliers
-- 1B+ (1000M+)		Mega funding / Pre-IPO / outliers

-- 3. So I want to know how many people laid off in each funding range and the average of them.
alter table present_layoffs_copy
add column `funding range` TEXT;

UPDATE present_layoffs_copy
set `funding range` = 
    CASE
		WHEN funds_raised_million IS NULL THEN NULL
        WHEN funds_raised_million < 60 THEN 'Under 60M'
        WHEN funds_raised_million >= 60 AND funds_raised_million <= 190 THEN '60M–190M'
        WHEN funds_raised_million > 190 AND funds_raised_million <= 535 THEN '190M–535M'
        WHEN funds_raised_million > 535 AND funds_raised_million <= 1000 THEN '535M–1B'
        ELSE '1B+'
    END
    ;
    
ALTER TABLE present_layoffs_copy
MODIFY COLUMN `funding range` TEXT
AFTER funds_raised_million;

-- 4. Are layoffs more common in certain countries or regions?
-- a. Total layoffs by country
SELECT 
    country,
    COUNT(*) AS num_layoff_events,
    SUM(total_laid_off) AS total_laid_off_country
FROM present_layoffs_copy
GROUP BY country
ORDER BY total_laid_off_country DESC;

-- 5. Are there seasonal or yearly trends in layoffs?
-- Layoffs by year
SELECT 
    YEAR(date) AS `year`,
    COUNT(*) AS num_layoff_events,
    SUM(total_laid_off) AS total_people_laid_off
FROM present_layoffs_copy
GROUP BY `year`
ORDER BY `year`;

-- b. Layoffs by month (across years)
SELECT 
    MONTH(`date`) AS `month`,
    COUNT(*) AS num_layoff_events,
    SUM(total_laid_off) AS total_people_laid_off
FROM present_layoffs_copy
GROUP BY `month`
ORDER BY `month`;

-- Top 10 countries having the most layoff:
SELECT 
    country, 
    sum(total_laid_off) as total_people_laid_off
FROM present_layoffs_copy
group by country
ORDER BY total_people_laid_off DESC
LIMIT 10;

-- Top 10 industries having the most layoff
SELECT 
    industry, 
    sum(total_laid_off) as total_people_laid_off
FROM present_layoffs_copy
group by industry
ORDER BY total_people_laid_off DESC
LIMIT 10;
-- 5. Are there seasonal or yearly trends in layoffs?

-- layoff time trend.
SELECT 
    `date`,
    COUNT(*) AS num_layoff_events,
    SUM(total_laid_off) AS total_laid_off
FROM 
    present_layoffs_copy
GROUP BY 
    `date`
ORDER BY 
    `date`;

-- this is for loading a column of num_layoff_events when I make dashboards in Excel
alter table present_layoffs_copy
drop column num_layoff_events;

select *
from present_layoffs_copy;

update present_layoffs_copy
set Tag = Case when trim(country) = 'United States' then 'U.S' else 'Non U.S' end;

ALTER TABLE present_layoffs_copy
MODIFY COLUMN laid_off_percent decimal(5,2)
AFTER total_laid_off;

ALTER TABLE present_layoffs_copy
MODIFY COLUMN country text
AFTER location;

ALTER TABLE present_layoffs_copy
MODIFY COLUMN Tag text
AFTER `funding range`;
	