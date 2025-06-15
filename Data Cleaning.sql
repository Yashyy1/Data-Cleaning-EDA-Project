-- Data cleaning

select * from layoffs;
-- 1. Remove Duplicates
-- 2. Standardize data(Check the data for any spelling, case or any other issues data solving them)
-- 3. NULL or Blank values
-- 4. Remove any columns which are not necessary


-- Create a dummy table to work with, because if we make some type of mistake we will have raw data available
create table layoffs_dummy like layoffs;

-- Insert data into layoffs_dummy from layoffs
insert layoffs_dummy select * from layoffs;

-- Identify duplicates, we will provide row number to the table based on partition by columns of the table

with dummy_cte as(
select *, 
row_number() over(
partition by company, industry, total_laid_off, percentage_laid_off, `date`, stage, country,
funds_raised_millions) 
as row_num from layoffs_dummy)
select * from dummy_cte where row_num > 1;

-- Deleting duplicates, delete those rows from layoffs_dummy whose row_num is greater than 1
-- If we try to delete the row_num>1 using delete statement then this will produce an error
-- so we create another table layoffs_dummy2 with the extra row_num column so that we can delete
-- duplicate rows 


CREATE TABLE `layoffs_dummy2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Insert data into layoffs_dummy2

insert into layoffs_dummy2
select *, 
row_number() over(
partition by company, industry, total_laid_off, percentage_laid_off, `date`, stage, country,
funds_raised_millions) 
as row_num from layoffs_dummy;

select * from layoffs_dummy2
where row_num > 1;

-- Deleting duplicate rows from layoffs_dummy2

delete from layoffs_dummy2 
where row_num > 1;

select * from layoffs_dummy2;

-- Standardization
-- trim white spaces from company, industry, location, stage, country names
select company,industry, location,stage,country ,
trim(company), trim(industry), trim(location), trim(stage), trim(country)
from layoffs_dummy2;

-- update table
update layoffs_dummy2
set company = trim(company),
industry = trim(industry),
location = trim(location),
stage = trim(stage),
country = trim(country)
;

-- Checking industry column for any issues
select distinct industry
from layoffs_dummy2
order by 1;

-- Here, we have a null and a blank value and there are 3 different names for same industry
-- i.e. Crypto, Crypto Currency, CryptoCurrency which needs to be standardized

update layoffs_dummy2
set industry = 'Crypto'
where industry like 'Crypto%';

-- We also have to standardize company named AppGate, Appgate
update layoffs_dummy2
set company = 'AppGate'
where company = 'Appgate';

-- Checking location column for any issues
select distinct location
from layoffs_dummy2
order by 1;

-- Checking country column for any issues
select distinct country 
from layoffs_dummy2
order by 1;

-- There are two entries for country United States(i.e. United States. and United States)
-- Updating table
update layoffs_dummy2
set country = 'United States'
where country like 'United States%';


-- The date column is defined as text, we need to change it to date
-- for this we will first convert the format of data in date column to date format
-- str_to_date takes two arguments column and the format in which we want it 
select `date`,
str_to_date(`date`,'%m/%d/%Y') 
from layoffs_dummy2;

-- Updating table
update layoffs_dummy2
set `date` = str_to_date(`date`,'%m/%d/%Y');

-- Changing the datatype
alter table layoffs_dummy2
modify column `date` date;

-- Working with null values and blank values


select * from layoffs_dummy2
where industry is null
or industry = '';

-- from above query we find that companies Airbnb, Bally's Interactive, Carvana, Juul have
-- blank and null values in industry column and now we will try to populate these values
-- based on other rows of the above company

select * from layoffs_dummy2
where company = 'Airbnb'
or company like 'Bally___Interactive'
or company = 'Carvana'
or company = 'Juul';

-- from above query we find that Airbnb is from Travel industry Carvana is from Transportation
-- industry and Juul is from Consumer industry, we did not get any information about the
-- industry to which Bally's Interactive belongs

-- Populating industry column with the information we got from above query
-- for this we will first change blank values to null
update layoffs_dummy2
set industry = null
where industry = '';

update layoffs_dummy2 t1
join layoffs_dummy2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null 
AND t2.industry is not null;


select * from layoffs_dummy2
where (total_laid_off is null or total_laid_off = '')
or (percentage_laid_off is null or percentage_laid_off = '')
or (funds_raised_millions is null or funds_raised_millions = '');

-- We also have null and blank values in total_laid_off, percentage_laid_off and 
-- funds_raised_millions columns but we do not have any related information in the table
-- using which we can populate their values

select * from layoffs_dummy2
where (total_laid_off is null or total_laid_off = '')
and (percentage_laid_off is null or percentage_laid_off = '');

-- from above query we find that there are plenty of rows in the table that have null values
-- in both total_laid_off and percentage_laid_off columns, these rows might create a problem
-- when we try to perform exploratory data analysis or create dashboards hence these rows must
-- be removed from the table

delete from layoffs_dummy2
where (total_laid_off is null or total_laid_off = '')
and (percentage_laid_off is null or percentage_laid_off = '');


-- Now we will drop row_num column from the table
alter table layoffs_dummy2
drop column row_num;

select * from layoffs_dummy2;






































