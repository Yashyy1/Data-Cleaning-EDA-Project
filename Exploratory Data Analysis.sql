SELECT * FROM layoffs_dummy2;

-- Max number of layoffs by a company in a day
select MAX(total_laid_off)
from layoffs_dummy2;

-- Max percentage of workforce laid off by a company
select MAX(percentage_laid_off)
from layoffs_dummy2;

-- How many companies laid off their entire workforce
select COUNT(percentage_laid_off)
from layoffs_dummy2
where percentage_laid_off = 1;

-- Which companies laid their entire workforce sorting them by total_laid_off and
-- funds_raised in descending order

select * 
from layoffs_dummy2
where percentage_laid_off = 1
order by total_laid_off desc;

select * 
from layoffs_dummy2
where percentage_laid_off = 1
order by funds_raised_millions desc;

-- Total number of employees laid off by the company from 2020 to 2023
select company, sum(total_laid_off)
from layoffs_dummy2
group by company
order by 2 desc;

-- How many people were laid off in each industry
select industry, sum(total_laid_off)
from layoffs_dummy2
group by industry
order by 2 desc;

-- How many people were laid off in each country
select country, sum(total_laid_off)
from layoffs_dummy2
group by country
order by 2 desc;

-- How many people were laid off in each year
select year(`date`), sum(total_laid_off)
from layoffs_dummy2
group by year(`date`)
order by 1 desc;

-- How many people were laid off by different companies based on there stage
select stage, sum(total_laid_off)
from layoffs_dummy2
group by stage
order by 2 desc;

-- Rolling total of laid offs over the 4 years month by month
with rolling_total as(
select substring(`date`,1,7) as `month`, sum(total_laid_off) as total
from layoffs_dummy2
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc)
select `month`,total, sum(total) over(order by `month`) as rolling
from rolling_total;

-- Ranking companies based on their lay offs per year
with company_rank_cte(company,`Year`,laid_off) as(
select company, year(`date`), sum(total_laid_off)
from layoffs_dummy2
group by company, year(`date`))
select *, dense_rank() over(partition by `Year` order by laid_off desc) as `RANK`
from company_rank_cte
order by `RANK`;

















