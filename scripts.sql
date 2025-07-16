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
