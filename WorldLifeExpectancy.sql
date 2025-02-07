# DATA CLEANING

# Function used to call the Table that we are going to use.
USE world_life_expectancy;
SELECT *
FROM worldlifeexpectancy;

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
				FROM(
					SELECT Row_ID, CONCAT(Country, Year), ROW_NUMBER() OVER( PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
					FROM worldlifeexpectancy
					) AS Row_table
				WHERE Row_Num > 1
                );


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

# EXPLORATORY DATA ANALYSIS

# "Life Expectancy" Column by Country
SELECT Country, 
MIN(`Life Expectancy`), 
MAX(`Life Expectancy`), 
ROUND((MAX(`Life Expectancy`) - MIN(`Life Expectancy`)), 1) AS life_expectancy_diff,
CONCAT(ROUND(((MAX(`Life Expectancy`) - MIN(`Life Expectancy`))/MIN(`Life Expectancy`)) * 100, 1), '%')  AS life_expectancy_growth
FROM worldlifeexpectancy
GROUP BY Country
ORDER BY life_expectancy_diff DESC;

# "GDP" Column by Country
SELECT Country, 
MIN(GDP), 
MAX(GDP), 
ROUND((MAX(GDP) - MIN(GDP)), 1) AS gdp_diff,
CONCAT(ROUND(((MAX(GDP) - MIN(GDP))/MIN(GDP)) * 100, 1), '%')  AS gdp_growth
FROM worldlifeexpectancy
GROUP BY Country
ORDER BY gdp_diff DESC;

# How the world "Life Expectancy" and "GDP" behave along those 15 years
SELECT Year, ROUND(AVG(`Life Expectancy`), 1) AS avg_life_exp, ROUND(AVG(GDP), 1) AS avg_gdp
FROM worldlifeexpectancy
GROUP BY Year
ORDER BY Year ASC;

# Is there any correlation between "Life Expectancy" and "GDP"?
SELECT Year, Country, `Life Expectancy`, GDP
FROM worldlifeexpectancy
HAVING Year IN (2007, 2012, 2017, 2022);

# Finding the median value in average GDP
WITH avg_country_gdp AS (
					SELECT Country, 
					ROUND(AVG(GDP), 1) AS avg_gdp
					FROM worldlifeexpectancy
					GROUP BY Country
                    ),
ordered AS (
			SELECT avg_gdp,
            ROW_NUMBER() OVER (ORDER BY avg_gdp) AS row_num,
            COUNT(*) OVER () AS total_rows
            FROM avg_country_gdp
            )
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





