-- creating global analysis database
CREATE DATABASE global_analysis;
USE global_analysis;
-- command to drop database; uncomment
-- DROP DATABASE IF EXISTS global_analysis;

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
