<h1 align="center">🌎 World Life Expectancy (WHO)</h1>
</br>


# Table of Contents

</br>

- [Project Overview](#project-overview)
- [Data Sources](#data-sources)
- [Tools](#tools)
- [Data Cleaning and Preparation](#data-cleaning-and-preparation)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Data Analysis](#data-analysis)
- [Results and Findings](#results-and-findings)
- [Recommendations](#recommendations)
- [Limitations](#limitations)
  
</br>

<h1 align="center">Project Overview</h1>

</br>
This project analyzes global life expectancy data from the World Health Organization (WHO), exploring trends and patterns across countries. It provides tools for data cleaning, analysis, and visualization to understand how life expectancy has evolved worldwide.
</br>
</br>

## Data Sources

</br>

World Life Expectancy Data: The primary dataset used for this analysis is the "WorldLifeExpectancy.csv" file, containing detailed information about each country and life expectancy and other variables.
- Download Databases [Click Here](https://www.who.int/data/gho/data/indicators)
  
</br>

## Tools

</br>

- SQL Server - Data Cleaning and Exploratory Data Analysis
- Python - Data Analysis
- Tableau - Data vizualisation
  
</br>

<h1 align="center">Data Cleaning and Preparation</h1>

</br>

In the initial data preparation phase, we performed the following tasks:

</br>

## 1. Data loading and inspection.

</br>

When we started analyzing the dataset, we noticed that:

- There were duplicated rows.
- Some items in the "Status" column were missing.
- Some items in the "Life Expectancy" column were missing.


</br>

## 2. Handling duplicated rows and missing values.

</br>

First, let's handle the duplicate rows using the following queries.

There are two columns that we can use to create a 'filter' for the duplicate rows. For each 'Country,' there is a corresponding 'Year,' and if we combine these two, we have a functional filter to identify duplicate rows:

</br>

```sql
# Finding the duplicate rows
SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year))
FROM worldlifeexpectancy
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) > 1;

# Finding the "Row_ID" correponding to the duplicate rows
SELECT *
FROM(
    SELECT Row_ID, CONCAT(Country, Year), ROW_NUMBER() OVER( PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
    FROM worldlifeexpectancy
    ) AS Row_table
WHERE Row_Num > 1;

# Deleting the duplicate rows
DELETE FROM worldlifeexpectancy
WHERE Row_ID IN (SELECT Row_ID
                FROM( SELECT Row_ID, CONCAT(Country, Year), ROW_NUMBER() OVER( PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
                    FROM worldlifeexpectancy) AS Row_table
                WHERE Row_Num > 1);
```

</br>

Now we need to address the blanks in the 'Status' column.

When we look at the data, we can observe that countries can be classified as 'Developed' or 'Developing.' The data is missing only for a few years, but not for all of them. To resolve this issue, we just need to check the type listed for the same country in another year.

</br>

```sql
# Finding the blanks or Nulls in "Status"
SELECT *
FROM worldlifeexpectancy
WHERE Status = '';

# Finding how many distinct status exists
SELECT DISTINCT(Status)
FROM worldlifeexpectancy
WHERE Status <> '';

# Updating the column with the missing values for Developing Countries
UPDATE worldlifeexpectancy a
JOIN worldlifeexpectancy b
  ON a.Country = b.Country
SET a.Status = 'Developing'
WHERE a.Status = ''
AND b.Status <> ''
AND b.Status = 'Developing';

# Updating the column with the missing values for Developed Countries
UPDATE worldlifeexpectancy a
JOIN worldlifeexpectancy b
  ON a.Country = b.Country
SET a.Status = 'Developed'
WHERE a.Status = ''
AND b.Status <> ''
AND b.Status = 'Developed';
``` 

</br>

Now we just need to find a solution for the missing values in the 'Life Expectancy' column.

It appears that for the missing values, the countries have been improving life expectancy each year. Therefore, we could assume the average value between the year before and after the missing data to fill in the 'Life Expectancy' column.

</br>

```sql
# Finding the Countries that "Life Expectancy" column is blank
SELECT *
FROM worldlifeexpectancy
WHERE `Life Expectancy` = '';

# Finding the average value for "Life Expectancy"
SELECT a.`Life Expectancy`,  b.`Life Expectancy`, c.`Life Expectancy`,
ROUND((b.`Life Expectancy` + c.`Life Expectancy`)/2, 1) AS avg_life_expectancy
FROM worldlifeexpectancy a
JOIN worldlifeexpectancy b
  ON a.Country = b.Country
  AND a.Year = b.Year - 1
JOIN worldlifeexpectancy c
  ON a.Country = c.Country
  AND a.Year = c.Year + 1
WHERE a.`Life Expectancy` = '';

# Updating the "Life Expectancy" column with the new values
UPDATE worldlifeexpectancy a
JOIN worldlifeexpectancy b
  ON a.Country = b.Country
  AND a.Year = b.Year - 1
JOIN worldlifeexpectancy c
  ON a.Country = c.Country
  AND a.Year = c.Year + 1
SET a.`Life Expectancy` = ROUND((b.`Life Expectancy` + c.`Life Expectancy`)/2, 1)
WHERE a.`Life Expectancy` = '';
```

</br>

<h1 align="center">Exploratory Data Analysis</h1>

</br>

EDA involved exploring the world life expectancy data to answer key questions, such as:

</br>

- How has Life Expectancy evolved over the years (min, max, and growth)?

</br>

```sql
# "Life Expectancy" Column by Country
SELECT Country, 
MIN(`Life Expectancy`), 
MAX(`Life Expectancy`), 
ROUND((MAX(`Life Expectancy`) - MIN(`Life Expectancy`)), 1) AS life_expectancy_diff,
CONCAT(ROUND(((MAX(`Life Expectancy`) - MIN(`Life Expectancy`))/MIN(`Life Expectancy`)) * 100, 1), '%')  AS life_expectancy_growth
FROM worldlifeexpectancy
GROUP BY Country
ORDER BY life_expectancy_diff DESC;
```
</br>

- How has GDP evolved over the years (min, max, and growth)?
</br>

```sql
# "GDP" Column by Country
SELECT Country, 
MIN(GDP), 
MAX(GDP), 
ROUND((MAX(GDP) - MIN(GDP)), 1) AS gdp_diff,
CONCAT(ROUND(((MAX(GDP) - MIN(GDP))/MIN(GDP)) * 100, 1), '%')  AS gdp_growth
FROM worldlifeexpectancy
GROUP BY Country
ORDER BY gdp_diff DESC;
```
</br>

- Is there any correlation between Life Expectancy and GDP, and if so, how does that correlation behave?
</br>

```sql
# How the world "Life Expectancy" and "GDP" behave along those 15 years
SELECT Year, ROUND(AVG(`Life Expectancy`), 1) AS avg_life_exp, ROUND(AVG(GDP), 1) AS avg_gdp
FROM worldlifeexpectancy
GROUP BY Year
ORDER BY Year ASC;

# Is there any correlation between "Life Expectancy" and "GDP"?
SELECT Year, Country, `Life Expectancy`, GDP
FROM worldlifeexpectancy
HAVING Year IN (2007, 2012, 2017, 2022);
```

</br>

- How many countries are above and below the GDP median? And what is the disparity between Life Expectancy and GDP for countries above and below the GDP median?

</br>

```sql
# Finding the median value in average GDP
WITH avg_country_gdp AS (
                        SELECT Country, 
                        ROUND(AVG(GDP), 1) AS avg_gdp
                        FROM worldlifeexpectancy
                        GROUP BY Country),
ordered AS (
            SELECT avg_gdp,
            ROW_NUMBER() OVER (ORDER BY avg_gdp) AS row_num,
            COUNT(*) OVER () AS total_rows
            FROM avg_country_gdp)
SELECT avg_gdp AS median
FROM ordered
WHERE row_num = (total_rows + 1)/2;

# Finding Countries that are above and below Median GDP
SELECT 
SUM(CASE WHEN GDP > 2000 THEN 1 ELSE 0 END) AS High_GDP_Count,
ROUND(AVG(CASE WHEN GDP > 2000 THEN `Life Expectancy` ELSE NULL END), 1) AS High_GDP_Life_Exp,
SUM(CASE WHEN GDP <= 2000 THEN 1 ELSE 0 END) AS Low_GDP_Count,
ROUND(AVG(CASE WHEN GDP <= 2000 THEN `Life Expectancy` ELSE NULL END), 1) AS Low_GDP_Life_Exp
FROM worldlifeexpectancy;
```

</br>

<h1 align="center">Data Analysis</h1>

</br>
Include some interesting code/features worked with

```sql
SELECT * FROM table1
WHERE cond = 2;
```
</br>

<h1 align="center">Results and Findings</h1>

</br>

The analysis results are summarized as follows:
- Over the last 15 years, African countries have experienced the highest average growth in Life Expectancy indicators.
- Over the last 15 years, it appears that the entire world has improved its GDP and Life Expectancy.
- With this data, we can assume that there is a slight correlation between GDP and Life Expectancy, but more data is needed to confirm this.
- There are some disparities that correlate with global inequality, as we have 1,192 countries above the median GDP and 1,746 countries below it. This shows that the GDPs above the median are significantly higher than the others, which skews the average upward.

</br>

<h1 align="center">Recommendations</h1>

</br>

Based on the analysis, we recommend the following actions:
- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.
- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.
- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.
  
</br>

<h1 align="center">Limitations</h1>

</br>

- Some values in the database are equal to zero because the WHO did not have the data. This usually indicates very small countries, where access to historical data is limited.
  - Some values in the "Life Expectancy" column are equal to zero.
  - Some values in the "GDP" column are equal to zero.
- Some values in the database seem to not accurately represent the real data.
  - For example, Spain's BMI appears to be significantly off (Database AVG: 58.67, while [INE Data](https://www.ine.es/jaxi/Datos.htm?tpx=49444) shows it to be around 16.01 in 2020).



