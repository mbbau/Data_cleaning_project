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

It's crucial that our data is accurate and reliable. This is why data cleaning is essential.

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

In order to make all of our data modifications while keeping the raw data intact, we need to create a new table that will be an exact copy of the layoffs table. This new table will be named layoffs_staging. The staging table allows us to perform data cleaning and transformations without affecting the original dataset, preserving data integrity and enabling us to backtrack or reference the original data if needed.

To create the layoffs_staging table and copy the data from the original layoffs table, we use the following SQL code:

```sql
-- Create an empty copy of the layoffs table structure
SELECT 
  * 
INTO 
  layoffs_staging
FROM
  layoffs
WHERE 1 = 0;  -- This condition prevents copying any data, keeping the table empty

-- Insert all data from layoffs into layoffs_staging
INSERT INTO layoffs_staging
SELECT
  * 
FROM 
  layoffs;

```

The first part of the code snippet creates an empty layoffs_staging table by copying the structure of the layoffs table but without transferring any data. The second part inserts all the data from layoffs into layoffs_staging, giving us a working copy of the original data that we can manipulate and clean.

## Common Data Cleaning Scenarios

Data cleaning is a crucial step in data analysis and preparation. It involves identifying and correcting errors or inconsistencies in a dataset to ensure that it is accurate, consistent, and usable for analysis. Here are some of the most common data cleaning scenarios encountered in any data project:

1. **Duplicate Values**: Duplicate values occur when the same record appears multiple times in a dataset. Duplicates can arise from various sources, such as data entry errors or system errors during data collection. These can skew the analysis by giving undue weight to repeated observations. Removing duplicates helps to maintain the integrity of the dataset and ensures accurate analysis.

2. **Missing or Null Values**: Missing values (also known as NULL values) are quite common in datasets. They can occur due to incomplete data entry, data corruption, or unavailability of certain information. Handling missing values is essential because they can affect the outcome of an analysis or even cause certain algorithms to fail. Common strategies to handle missing values include imputation, deletion, or replacing them with default values.

3. **Inconsistent Data Formatting**: Data from multiple sources can often be inconsistent in format. For example, dates may be formatted differently (e.g., MM/DD/YYYY vs. DD-MM-YYYY), or text fields may have different casing (New York vs. new york). Standardizing data formatting ensures consistency and avoids issues during analysis or visualization.

4. **Outliers**: Outliers are data points that significantly differ from other observations. While they can sometimes indicate errors in data collection or entry, outliers can also reveal important insights, such as anomalies or fraud detection. Identifying and handling outliers correctly is crucial to avoid skewing the analysis results.

5. **Incorrect Data Types**: Sometimes data is stored in the wrong format or data type (e.g., a numeric field stored as text). Ensuring that each column has the correct data type is vital for performing mathematical operations, sorting, filtering, and joining datasets correctly.

6. **Irrelevant or Redundant Columns**: Datasets often contain columns that are not relevant to the analysis at hand. Removing unnecessary columns helps simplify the dataset, reduces noise, and improves the performance of data processing.

7. **Data Entry Errors**: Typographical errors or incorrect values can occur during data entry, especially in manual processes. Detecting and correcting these errors is necessary to ensure data quality.

8. **Normalization and Standardization**: Data normalization involves scaling the data to fit within a particular range (e.g., 0 to 1), which is especially useful when using algorithms that are sensitive to data scales. Standardization involves transforming data to have a mean of zero and a standard deviation of one.

By addressing these common data cleaning scenarios, we ensure that our dataset is ready for analysis, reducing the risk of misleading results and improving the reliability of any insights drawn from the data.

### Duplicate Values

In order to remove duplicates, we first need to indentify them. One of the ways to identify duplicates is to group them and count the ocurrences. The next code do this in sql, by using a window function:

```sql

WITH duplicate_cte AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY company, industry, total_laid_off, percentage_laid_off, date 
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

```
In this case, we did not have a unique identifier on the column. If you have a unique identifier, you could just group by the identifier column and the count the unique values. Any counted value greater than 1 could be a duplicate and should be remove after carefull anaylisis. 
If we compare this SQL code to the same code in M language that means to achieve the same, we can see the simplicity of M code:

```M

= Table.Distinct(
  Previos_Step, 
  {"company", "industry", "total_laid_off", "percentage_laid_off"}
  )

```
So, why if it is so simple in M, we want to do this in SQL. This is because we want to make all the transformations as close to source of the data as posible, in order to fully leverage the compute power of the Data Base.