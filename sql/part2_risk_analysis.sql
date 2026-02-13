-- Exploratory Data Analysis (Part 2)

SELECT * 
FROM layoffs_staging2
;

-- Identify the largest layoff event and highest percentage of workforce laid off
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2
;

-- Companies that laid off 100% of employees (bankrupt/shut down)
SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC
;

-- When layoffs started and ended (date range)
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2
;

-- Total layoffs by company
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC
;

-- Total layoffs by industry
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC
;

-- Total layoffs by country
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC
;

-- Total layoffs by year
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC
;

-- Total layoffs by company stage
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC
;

-- Monthly layoffs over time
SELECT SUBSTRING(`date`, 1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
;

-- Cumulative (rolling) layoffs by month
WITH Rolling_total AS
(
SELECT SUBSTRING(`date`, 1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off
,SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_total
;

-- Total layoffs by company and year
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC
;

-- Top 5 companies by layoffs per year
WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) as Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5
;

-- Risk by industry
SELECT
    industry,
    COUNT(*) AS total_events,
    SUM(total_laid_off) AS total_people_laid_off,
    ROUND(AVG(percentage_laid_off), 2) AS avg_percent_laid_off,
    SUM(CASE WHEN percentage_laid_off >= 0.5 THEN 1 ELSE 0 END) AS high_severity_events_50_percent_plus,
    SUM(CASE WHEN percentage_laid_off = 1 THEN 1 ELSE 0 END) AS full_shutdown_events_100_percent
FROM layoffs_staging2
WHERE industry IS NOT NULL
GROUP BY industry
ORDER BY avg_percent_laid_off DESC
;

-- Risk by stage 
SELECT
    stage,
    COUNT(*) AS total_events,
    SUM(total_laid_off) AS total_people_laid_off,
    ROUND(AVG(percentage_laid_off), 2) AS avg_percent_laid_off,
    SUM(CASE WHEN percentage_laid_off >= 0.5 THEN 1 ELSE 0 END) AS high_severity_events_50_percent_plus,
    SUM(CASE WHEN percentage_laid_off = 1 THEN 1 ELSE 0 END) AS full_shutdown_events_100_percent
FROM layoffs_staging2
WHERE stage IS NOT NULL
GROUP BY stage
ORDER BY avg_percent_laid_off DESC
;

-- Industry layoff frequency and average % reduction
SELECT 
    industry,
    COUNT(*) AS events,
    ROUND(AVG(percentage_laid_off),2) AS avg_pct_laid_off
FROM layoffs_staging2
WHERE percentage_laid_off IS NOT NULL
GROUP BY industry
HAVING COUNT(*) >= 5
ORDER BY avg_pct_laid_off DESC
;
