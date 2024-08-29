DROP TABLE dbo.layoffs

CREATE TABLE layoffs (
    company VARCHAR(100),
    location VARCHAR(100),
    industry VARCHAR(100),
    total_laid_off VARCHAR(100) NULL,
    percentage_laid_off VARCHAR(100) NULL,
    date VARCHAR(100),
    stage VARCHAR(100),
    country VARCHAR(100),
    funds_raised_millions VARCHAR(100)
)


BULK INSERT layoffs
FROM 'C:\Users\usuario\Documents\Matias\Proyectos personales\Data_cleaning_project\data\layoffs.csv'
WITH (
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',   
    FIRSTROW = 2           
)


SELECT * INTO layoffs_staging
FROM layoffs
WHERE 1 = 0;

INSERT INTO layoffs_staging
SELECT * FROM layoffs;

WITH duplicate_cte AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY company, 'location', industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions  
			ORDER BY (SELECT NULL)  
        ) AS row_num
    FROM layoffs_staging
)

SELECT 
  *
FROM 
  duplicate_cte
WHERE 
  row_num > 1;


SELECT 
    company, 
    location, 
    industry,
	total_laid_off, 
	percentage_laid_off,
    date,
    COUNT(*) AS duplicate_count
FROM 
    layoffs_staging
GROUP BY 
    company, 
    location, 
    industry, 
    date,
	total_laid_off, 
	percentage_laid_off
HAVING 
    COUNT(*) > 1;  -- Mostrar solo los grupos que tienen más de una ocurrencia


-- Delete the duplicate rows
DELETE
FROM duplicate_cte
WHERE row_num > 1;

UPDATE layoffs_staging
SET company = TRIM(company)

UPDATE layoffs_staging
SET 
  indystry = 'Crypto'
WHERE
  industry LIKE 'Crypto%';

SELECT 
  DISTINCT status
FROM 
  sales
WHERE
  status NOT IN ('Shipped', 'Delivered', 'Pending', 'Returned');

UPDATE sales
SET status = CASE
    WHEN status IN ('Shipped ', 'shipped') THEN 'Shipped'
    WHEN status IN ('delivered', 'Deliverd') THEN 'Delivered'
    WHEN status IN ('pendin', 'pendding') THEN 'Pending'
    WHEN status IN ('Returnd', 'Rturn') THEN 'Returned'
    ELSE status
END;

UPDATE layoffs_staging
SET 
  status = TRIM(status);
