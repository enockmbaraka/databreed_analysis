-- creating a database and using it
CREATE DATABASE global_analysis;
USE global_analysis;

DROP DATABASE IF EXISTS global_analysis;

-- Create tables without foreign keys
CREATE TABLE IF NOT EXISTS gdp_2020 (
    Country VARCHAR(100) PRIMARY KEY,
    Nominal_gdp_per_capita DECIMAL(15,3) NOT NULL,
    PPP_gdp_per_capita DECIMAL(15,3) NOT NULL,
    GDP_growth_percentage DECIMAL(5,3),
    Rise_fall_GDP VARCHAR(100)
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
