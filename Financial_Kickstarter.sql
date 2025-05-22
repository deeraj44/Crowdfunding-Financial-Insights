CREATE DATABASE da_project_CF;
USE da_project_CF;

CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    name TEXT,
    category_id INT,
    currency_code VARCHAR(10),
    country_code VARCHAR(10),
    launch_id INT,
    goal DECIMAL(12, 2),
    pledged DECIMAL(12, 2),
    usd_pledged DECIMAL(12, 2),
    backers INT,
    state VARCHAR(50)
);
LOAD DATA LOCAL INFILE 'C:/Users/deera/Downloads/projects.csv'
INTO TABLE projects
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category VARCHAR(100),
    main_category VARCHAR(100)
);
LOAD DATA LOCAL INFILE 'C:/Users/deera/Downloads/categories.csv'
INTO TABLE categories
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

CREATE TABLE currencies (
    currency_code VARCHAR(10) PRIMARY KEY
);
LOAD DATA LOCAL INFILE 'C:/Users/deera/Downloads/currencies.csv'
INTO TABLE currencies
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

CREATE TABLE countries (
    country_code VARCHAR(10) PRIMARY KEY
);

LOAD DATA LOCAL INFILE 'C:/Users/deera/Downloads/countries.csv'
INTO TABLE countries
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

CREATE TABLE launch_dates (
    launch_id INT PRIMARY KEY AUTO_INCREMENT,
    launched DATETIME,
    deadline DATETIME
);
LOAD DATA LOCAL INFILE 'C:/Users/deera/Downloads/launch_dates.csv'
INTO TABLE launch_dates
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- Success Rate by Main Category
SELECT 
    c.main_category,
    COUNT(*) AS total_campaigns,
    SUM(CASE WHEN p.state = 'successful' THEN 1 ELSE 0 END) AS successful_campaigns,
    ROUND(SUM(CASE WHEN p.state = 'successful' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS success_rate_percentage
FROM projects p
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.main_category
ORDER BY success_rate_percentage DESC;

-- Average Funding by Country (Handling Missing Values with COALESCE)
SELECT 
    co.country_code,
    COALESCE(ROUND(AVG(p.usd_pledged), 2), 0) AS avg_usd_pledged
FROM projects p
JOIN countries co ON p.country_code = co.country_code
GROUP BY co.country_code
ORDER BY avg_usd_pledged DESC;

-- Fixing the query 
UPDATE projects
SET country_code = NULL
WHERE country_code NOT REGEXP '^[A-Z]{2}$';

SELECT 
    co.country_code,
    COALESCE(ROUND(AVG(p.usd_pledged), 2), 0) AS avg_usd_pledged
FROM projects p
JOIN countries co ON p.country_code = co.country_code
GROUP BY co.country_code
ORDER BY avg_usd_pledged DESC;

--  Top 5 Most Funded Categories (with CTE)
WITH category_totals AS (
    SELECT 
        c.category,
        SUM(p.usd_pledged) AS total_pledged
    FROM projects p
    JOIN categories c ON p.category_id = c.category_id
    GROUP BY c.category
)
SELECT * FROM category_totals
ORDER BY total_pledged DESC
LIMIT 5;

-- Funding Goal Buckets (with CASE)
SELECT 
    CASE 
        WHEN goal < 1000 THEN 'Low (<$1k)'
        WHEN goal BETWEEN 1000 AND 10000 THEN 'Medium ($1k–$10k)'
        WHEN goal BETWEEN 10001 AND 50000 THEN 'High ($10k–$50k)'
        ELSE 'Very High (>$50k)'
    END AS goal_range,
    COUNT(*) AS num_projects,
    ROUND(AVG(usd_pledged), 2) AS avg_pledged
FROM projects
GROUP BY goal_range
ORDER BY avg_pledged DESC;






-- 
