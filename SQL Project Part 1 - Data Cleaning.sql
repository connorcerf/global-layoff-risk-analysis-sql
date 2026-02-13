-- Data Cleaning (Part 1)

-- Goals:
-- 1.) Remove Duplicates
-- 2.) Standardize Values
-- 3.) Null & Blank Values
-- 4.) Remove Columns

-- Review raw data
SELECT * 
FROM layoffs
;

-- Create staging table to preserve raw data 
CREATE TABLE layoffs_staging
LIKE layoffs
;

-- Copy raw data into staging table
INSERT layoffs_staging
SELECT *
FROM layoffs; 

SELECT * 
FROM layoffs_staging
;


-- (IDENTIFYING AND REMOVING DUPLICATES)

-- Identify potential duplicate rows using window function
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging
;

-- Confirm duplicates across all relevant columns
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, 
industry, total_laid_off, percentage_laid_off, `date`, stage
, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1
;

-- Manually inspecting example duplicate
SELECT *
FROM layoffs_staging
WHERE company = 'Casper'
;

-- Create second staging table to safely remove duplicates
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Inserting data while assigning row numbers for duplicate removal
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, 
industry, total_laid_off, percentage_laid_off, `date`, stage
, country, funds_raised_millions) AS row_num
FROM layoffs_staging
;

-- Identify duplicate rows
SELECT *
FROM layoffs_staging2
WHERE row_num > 1
;

-- Remove duplicate records
DELETE
FROM layoffs_staging2
WHERE row_num > 1
;

SELECT *
FROM layoffs_staging2
;


-- (STANDARDIZING THE DATA)

-- Identify inconsistent company name formatting
SELECT DISTINCT(company)
FROM layoffs_staging2
;

SELECT DISTINCT(TRIM(company))
FROM layoffs_staging2
;

SELECT company, (TRIM(company))
FROM layoffs_staging2
;

-- Trim leading and trailing whitespace from company names
UPDATE layoffs_staging2
SET company = TRIM(company)
;

-- Review distinct industry values
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1
;

SELECT * 
FROM layoffs_staging2 
WHERE industry LIKE 'Crypto%'
;

-- Standardize crypto-related industry labels
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%'
;

-- Identify inconsistent country formatting
SELECT DISTINCT country 
FROM layoffs_staging2 
WHERE country LIKE 'United States%'
ORDER BY 1
;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2 
ORDER BY 1
;

-- Remove trailing punctuation from country names
UPDATE layoffs_staging2 
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%'
;

SELECT `date`, 
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2
;

-- Convert date values from text to DATE format
UPDATE layoffs_staging2 
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
;

SELECT `date`
FROM layoffs_staging2
;

-- Update column data type for date
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE 
;

SELECT * 
FROM layoffs_staging2
;


-- (NULLS AND BLANK VALUES)

-- Identify rows missing corresponding layoff metrics
SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

-- Converting empty values to NULL
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = ''
;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = ''
;

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb'
;

-- Validate industry consistency by company
SELECT t1.industry, t2.industry
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND  t2.industry IS NOT NULL
; 

-- Populate missing industry values using known company records
UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL
;

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%'
;


-- (REMOVING COLUMNS/ROWS)

-- Remove rows with no usable layoff data
DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

-- Drop helper column used for duplicate removal (row_num)
ALTER TABLE layoffs_staging2
DROP COLUMN row_num
;

SELECT *
FROM layoffs_staging2
;

-- Data Quality Summary
-- 1.) Duplicate records removed using window functions across all business-critical columns.
-- 2.) Text fields standardized (company, industry, country) to ensure consistent grouping.
-- 3.) Date column converted from text to DATE data type for analysis.
-- 4.) Blank values normalized to NULL for accurate filtering and aggregation.
-- 5.) Missing industry values populated where possible using company-level consistency.
-- 6.) Rows with no usable layoff metrics removed to prevent skewed analysis.
