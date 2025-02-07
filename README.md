<h1 align="center">🌎 World Life Expectancy (WHO)</h1>
</br>


# Table of Contents

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

- SQL Server - Data Cleaning and Data Analysis
  
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

## 2. Handling missing values.

</br>

First, let's handle the duplicate rows using the following queries.

There are two columns that we can use to create a 'filter' for the duplicate rows. For each 'Country,' there is a corresponding 'Year,' and if we combine these two, we have a functional filter to identify duplicate rows:

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

<h1 align="center">Exploratory Data Analysis</h1>

</br>
EDA involved exploring the world life expectancy data to answer key questions, such as:

- xxxxxxxxxxxxxxxxxxxxxxxxxxxx?
- xxxxxxxxxxxxxxxxxxxxxxxxxxxx?
- xxxxxxxxxxxxxxxxxxxxxxxxxxxx?
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
- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.
- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.
- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.

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

- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.



