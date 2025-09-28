-- Exploratory data analysis 

SELECT * 
FROM layoffs_staging2;

-- Find the maximum number of layoffs and the maximum layoff percentage
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Show companies with 100% layoffs, ordered by funds raised
SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Total layoffs per company
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Earliest and latest layoff dates
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- Total layoffs by industry
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Total layoffs by country
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Total layoffs per year
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;

-- Total layoffs by company stage
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- Average layoff percentage by company
SELECT company, AVG(percentage_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Monthly layoffs (YYYY-MM)
SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

-- Monthly layoffs with rolling cumulative total
WITH Rolling_total AS
(
    SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) AS total_off
    FROM layoffs_staging2
    WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
    GROUP BY `MONTH`
    ORDER BY 1 ASC
)
SELECT `MONTH`, total_off,
       SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_total;

-- Total layoffs per company per year
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

-- Rank companies by layoffs within each year
WITH company_year(company, years, total_laid_off) AS
(
    SELECT company, YEAR(`date`), SUM(total_laid_off)
    FROM layoffs_staging2
    GROUP BY company, YEAR(`date`)
)
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM company_year
WHERE years IS NOT NULL
ORDER BY ranking ASC;

-- Top 5 companies with most layoffs each year
WITH company_year(company, years, total_laid_off) AS
(
    SELECT company, YEAR(`date`), SUM(total_laid_off)
    FROM layoffs_staging2
    GROUP BY company, YEAR(`date`)
), company_year_rank AS
(
    SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
    FROM company_year
    WHERE years IS NOT NULL
)
SELECT *
FROM company_year_rank
WHERE ranking <= 5;
