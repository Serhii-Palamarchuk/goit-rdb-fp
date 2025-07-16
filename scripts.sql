/*--- Крок 1: Створення схеми та імпорт даних ---*/
CREATE SCHEMA pandemic;
USE pandemic;

SELECT COUNT(*) FROM infectious_cases;

DESCRIBE infectious_cases;

/*--- Крок 2: Нормалізація до 3НФ ---*/

-- 2.1. Створимо окрему таблицю entities
CREATE TABLE entities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entity_name VARCHAR(255) NOT NULL,
    code VARCHAR(50) NOT NULL,
    UNIQUE(entity_name, code)
);

INSERT INTO entities (entity_name, code)
SELECT DISTINCT Entity, Code
FROM infectious_cases;

SELECT * FROM entities;

-- 2.2. Створимо таблицю з нормалізованими даними
CREATE TABLE infectious_data (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entity_id INT,
    year INT,
    number_yaws DOUBLE,
    polio_cases DOUBLE,
    cases_guinea_worm DOUBLE,
    number_rabies DOUBLE,
    number_malaria DOUBLE,
    number_hiv DOUBLE,
    number_tuberculosis DOUBLE,
    number_smallpox DOUBLE,
    number_cholera_cases DOUBLE,
    FOREIGN KEY (entity_id) REFERENCES entities(id)
);

INSERT INTO infectious_data (entity_id, year, number_yaws, polio_cases, cases_guinea_worm, number_rabies, number_malaria, number_hiv, number_tuberculosis, number_smallpox, number_cholera_cases)
SELECT 
    e.id,
    ic.Year,
    ic.Number_yaws,
    ic.polio_cases,
    ic.cases_guinea_worm,
    ic.Number_rabies,
    ic.Number_malaria,
    ic.Number_hiv,
    ic.Number_tuberculosis,
    ic.Number_smallpox,
    ic.Number_cholera_cases
FROM infectious_cases ic
JOIN entities e ON ic.Entity = e.entity_name AND ic.Code = e.code;

SELECT * FROM infectious_data;

-- 2.3. Кількість після нормалізації
SELECT 'entities', COUNT(*) FROM entities
UNION ALL
SELECT 'infectious_data', COUNT(1) FROM infectious_data;

/*--- Крок 3: Агреґація по Number_rabies ---*/
SELECT 
    e.entity_name,
    e.code,
    COUNT(*) AS total_rows,
    AVG(idata.number_rabies) AS avg_rabies,
    MIN(idata.number_rabies) AS min_rabies,
    MAX(idata.number_rabies) AS max_rabies,
    SUM(idata.number_rabies) AS sum_rabies
FROM infectious_data idata
JOIN entities e ON idata.entity_id = e.id
WHERE idata.number_rabies IS NOT NULL
GROUP BY e.entity_name, e.code
ORDER BY avg_rabies DESC
LIMIT 10;

/*--- Крок 4: “різниця в роках” через вбудовані функції ---*/
SELECT
    d.id,
    d.year,
    STR_TO_DATE(CONCAT(d.year, '-01-01'), '%Y-%m-%d') AS year_start,
    CURDATE() AS today,
    TIMESTAMPDIFF(
        YEAR,
        STR_TO_DATE(CONCAT(d.year, '-01-01'), '%Y-%m-%d'),
        CURDATE()
    ) AS years_diff
FROM infectious_data d
LIMIT 20;

/*--- Крок 5: власна функція ---*/
DELIMITER $$
CREATE FUNCTION years_since (_year INT)
RETURNS INT
DETERMINISTIC
BEGIN
  RETURN TIMESTAMPDIFF(
           YEAR,
           STR_TO_DATE(CONCAT(_year, '-01-01'), '%Y-%m-%d'),
           CURDATE()
         );
END$$
DELIMITER ;

-- Використання:
SELECT
    d.id,
    d.year,
    years_since(d.year) AS years_diff
FROM infectious_data d
LIMIT 20;

