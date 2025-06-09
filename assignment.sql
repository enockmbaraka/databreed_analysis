CREATE DATABASE global_analysis;
USE global_analysis;

DROP DATABASE IF EXISTS global_analysis;

-- Create tables without foreign keys
CREATE TABLE IF NOT EXISTS gdp_2020 (
    Country VARCHAR(100) PRIMARY KEY,
    Nominal_gdp_per_capita DECIMAL(15,3) NOT NULL,
    PPP_gdp_per_capita DECIMAL(15,3) NOT NULL,
    GDP_growth_percentage DECIMAL(5,3),
    Rise_fall_GDP VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS covid_19 (
    Country VARCHAR(100) PRIMARY KEY,
    Confirmed INT NOT NULL,
    Deaths INT NOT NULL,
    Recovered INT NOT NULL,
    Active INT NOT NULL,
    New_cases INT,
    New_deaths INT,
    New_recovered INT,
    WHO_Region VARCHAR(50)
);

-- Load GDP data
LOAD DATA INFILE '/var/lib/mysql-files/gdp_2020.csv'
INTO TABLE gdp_2020
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Load COVID data
LOAD DATA INFILE '/var/lib/mysql-files/covid_19.csv'
INTO TABLE covid_19
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- Clean up non-matching countries from covid_19 table
-- This ensures only countries present in gdp_2020 remain in covid_19
DELETE FROM covid_19 
WHERE Country NOT IN (SELECT Country FROM gdp_2020);

-- Add the foreign key constraint after data is loaded
ALTER TABLE covid_19
ADD CONSTRAINT fk_covid_country
FOREIGN KEY (Country) REFERENCES gdp_2020(Country)
ON DELETE CASCADE
ON UPDATE CASCADE;


-- Task 3
--
SELECT 
    Country,
    Confirmed,
    Deaths,
    ROUND((Deaths * 100.0 / Confirmed), 2) AS death_rate_percentage
FROM 
    covid_19
WHERE 
    WHO_Region = 'Europe'
    AND Confirmed > 10000
ORDER BY 
    death_rate_percentage DESC;
    
 -- task 4
SELECT 
    g.Country,
    g.GDP_growth_percentage,
    c.Deaths AS COVID_Deaths
FROM 
    gdp_2020 g
JOIN 
    covid_19 c ON g.Country = c.Country
WHERE 
    g.Rise_fall_GDP = 'short fall'
ORDER BY 
    c.Deaths DESC;
    
 --
SELECT 
    g.Country,
    g.GDP_growth_percentage,
    c.Deaths AS COVID_Deaths
FROM 
    gdp_2020 g
JOIN 
    covid_19 c ON g.Country = c.Country
WHERE 
    g.Rise_fall_GDP = 'High fall'
ORDER BY 
    c.Deaths DESC;
 
 -- task 5
SHOW COLUMNS FROM gdp_2020;

-- Rank countries by GDP per capita in descending order (highest GDP gets rank 1)
WITH gdp_ranked AS (
    SELECT 
        Country, 
        Nominal_gdp_per_capita,
        DENSE_RANK() OVER (ORDER BY Nominal_gdp_per_capita DESC) AS gdp_rank
    FROM gdp_2020
),

-- Select countries that are in the top 10% by GDP per capita based on their rank
gdp_top_10 AS (
    SELECT Country
    FROM gdp_ranked
    WHERE gdp_rank <= CEIL((SELECT COUNT(*) FROM gdp_2020) * 0.1)  -- Top 10% threshold
),

-- Rank countries by COVID deaths in descending order (highest deaths gets rank 1)
covid_ranked AS (
    SELECT 
        Country, 
        Deaths,
        DENSE_RANK() OVER (ORDER BY Deaths DESC) AS death_rank
    FROM covid_19
),

-- Select countries that are in the top 10% by COVID deaths based on their rank
deaths_top_10 AS (
    SELECT Country
    FROM covid_ranked
    WHERE death_rank <= CEIL((SELECT COUNT(*) FROM covid_19) * 0.1)  -- Top 10% threshold
)

-- Final selection:
-- 1) Countries in top 10% GDP but NOT in top 10% deaths, labeled accordingly
SELECT Country, 'High GDP per capita' AS Category
FROM gdp_top_10
WHERE Country NOT IN (SELECT Country FROM deaths_top_10)

UNION

-- 2) Countries in top 10% deaths but NOT in top 10% GDP, labeled accordingly
SELECT Country, 'High Deaths' AS Category
FROM deaths_top_10
WHERE Country NOT IN (SELECT Country FROM gdp_top_10);


--
UPDATE covid_19
SET WHO_Region = TRIM(WHO_Region);

--
UPDATE covid_19
SET WHO_Region = TRIM(REPLACE(REPLACE(REPLACE(WHO_Region, '\r', ''), '\n', ''), '\t', ''))
WHERE WHO_Region LIKE '%Europe%';



