# Data cleaning project

In this repository, you'll find a comprehensive guide to data cleaning and manipulation using SQL. We'll explore why data cleaning is crucial for any data-driven project, the common challenges faced in the process, and various SQL techniques to effectively clean and prepare data.

## Why is Data Cleaning Important?

Data cleaning is crucial for ensuring accurate analysis and better decision-making. Consider a scenario where you are analyzing your best-selling products from the last quarter. To do this, you might perform a simple calculation by grouping the total sales amount for each product:


```sql
SELECT
  product_name,
  SUM(amount) AS total_amount
FROM
  sales.sales
WHERE
  date >= 'start_date' AND date <= 'end_date' -- Filter to get the last quarter
GROUP BY 
  product_name
ORDER BY
  total_amount DESC
```

After running this query, you might get the following results:

* item1: $5000
* item7: $3500
* item3: $1500
* item_7: $3500

As you can see, there is a naming inconsistency with "item7" and "item_7," causing them to appear as two different products. This small detail can lead to incorrect conclusions, showing "item1" as the best product when, in reality, "item7" would be the top seller if the two entries were combined—by 40% higher!

And now, suppose you discover that many sales were registered twice, resulting in duplicate values. Upon removing these duplicates, the real total amount for "item7" turns out to be $5600, which is still higher than "item1". These two types of issues—naming inconsistencies and duplicate records—demonstrated in the previous simple example, can mislead decision-makers, potentially leading to incorrect business strategies and unforeseen consequences.

Therefore, after any type of analysis, it's crucial that our data is accurate and reliable. This is why data cleaning is essential.

## Creating the table we are going to use

For this project, I am using Microsoft SQL Server and a dataset about World Layoffs, which you can find in the data folder. This dataset is provided by [Alex The Analyst](https://github.com/AlexTheAnalyst/MySQL-YouTube-Series/blob/main/layoffs.csv).

The following code snippet creates a table in SQL Server and imports the data from the CSV file:

```sql

IF OBJECT_ID('dbo.layoffs', 'U') IS NOT NULL
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

```

