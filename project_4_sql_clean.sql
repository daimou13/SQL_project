-- =============================================================
-- ENGETO Data Academy - Project 4: SQL
-- Author: Dmytro Syrvatka
-- =============================================================


-- =============================================================
-- 1. PRIMARY FINAL TABLE
-- Wages by industry and year + food prices by category and year
-- Period: 2006-2018
-- =============================================================

DROP TABLE IF EXISTS t_dmytro_syrvatka_project_sql_primary_final;

CREATE TABLE t_dmytro_syrvatka_project_sql_primary_final AS
WITH wages AS (
    SELECT
        cp.payroll_year AS year,
        cp.industry_branch_code,
        cpib.name AS industry_name,
        ROUND(AVG(cp.value)::numeric, 2) AS average_wage
    FROM czechia_payroll cp
    JOIN czechia_payroll_industry_branch cpib
        ON cp.industry_branch_code = cpib.code
    WHERE cp.value_type_code = 5958
      AND cp.unit_code = 200
      AND cp.calculation_code = 200
      AND cp.value IS NOT NULL
      AND cp.payroll_year BETWEEN 2006 AND 2018
    GROUP BY
        cp.payroll_year,
        cp.industry_branch_code,
        cpib.name
),
prices AS (
    SELECT
        EXTRACT(YEAR FROM cp.date_from)::int AS year,
        cp.category_code,
        cpc.name AS food_name,
        cpc.price_value,
        cpc.price_unit,
        ROUND(AVG(cp.value)::numeric, 2) AS average_price
    FROM czechia_price cp
    JOIN czechia_price_category cpc
        ON cp.category_code = cpc.code
    WHERE cp.region_code IS NULL
    GROUP BY
        EXTRACT(YEAR FROM cp.date_from),
        cp.category_code,
        cpc.name,
        cpc.price_value,
        cpc.price_unit
)
SELECT
    w.year,
    w.industry_branch_code,
    w.industry_name,
    w.average_wage,
    p.category_code,
    p.food_name,
    p.price_value,
    p.price_unit,
    p.average_price
FROM wages w
JOIN prices p
    ON w.year = p.year;


-- =============================================================
-- 2. SECONDARY FINAL TABLE
-- GDP, GINI and population for European countries, 2006-2018
-- =============================================================

DROP TABLE IF EXISTS t_dmytro_syrvatka_project_sql_secondary_final;

CREATE TABLE t_dmytro_syrvatka_project_sql_secondary_final AS
SELECT
    e.country,
    e.year,
    e.gdp,
    e.gini,
    e.population
FROM economies e
JOIN countries c
    ON e.country = c.country
WHERE c.continent = 'Europe'
  AND e.year BETWEEN 2006 AND 2018;


-- =============================================================
-- RESEARCH QUESTION 1
-- Do wages grow in all industries over the years,
-- or do they decrease in some industries?
-- =============================================================

WITH wages AS (
    SELECT DISTINCT
        year,
        industry_branch_code,
        industry_name,
        average_wage
    FROM t_dmytro_syrvatka_project_sql_primary_final
),
wages_with_previous_year AS (
    SELECT
        year,
        industry_branch_code,
        industry_name,
        average_wage,
        LAG(average_wage) OVER (
            PARTITION BY industry_branch_code
            ORDER BY year
        ) AS previous_year_wage
    FROM wages
),
wage_changes AS (
    SELECT
        year,
        industry_branch_code,
        industry_name,
        average_wage,
        previous_year_wage,
        ROUND(
            (
                (average_wage - previous_year_wage)
                / previous_year_wage
            ) * 100,
            2
        ) AS wage_growth_percent
    FROM wages_with_previous_year
)
SELECT
    year,
    industry_branch_code,
    industry_name,
    average_wage,
    previous_year_wage,
    wage_growth_percent
FROM wage_changes
WHERE wage_growth_percent < 0
ORDER BY
    year,
    industry_branch_code;


-- =============================================================
-- RESEARCH QUESTION 2
-- How many litres of milk and kilograms of bread could be bought
-- for the average wage in the first and last comparable period?
-- =============================================================

WITH wages AS (
    SELECT
        year,
        ROUND(AVG(average_wage), 2) AS average_wage
    FROM (
        SELECT DISTINCT
            year,
            industry_branch_code,
            average_wage
        FROM t_dmytro_syrvatka_project_sql_primary_final
    ) w
    WHERE year IN (2006, 2018)
    GROUP BY year
),
prices AS (
    SELECT DISTINCT
        year,
        category_code,
        food_name,
        price_unit,
        average_price
    FROM t_dmytro_syrvatka_project_sql_primary_final
    WHERE category_code IN (111301, 114201)
      AND year IN (2006, 2018)
)
SELECT
    p.year,
    p.food_name,
    p.price_unit,
    w.average_wage,
    p.average_price,
    ROUND(w.average_wage / p.average_price, 2) AS purchasable_amount
FROM prices p
JOIN wages w
    ON p.year = w.year
ORDER BY
    p.year,
    p.category_code;


-- =============================================================
-- RESEARCH QUESTION 3
-- Which food category has the lowest average year-on-year
-- percentage price increase?
-- =============================================================

WITH prices AS (
    SELECT DISTINCT
        year,
        category_code,
        food_name,
        average_price
    FROM t_dmytro_syrvatka_project_sql_primary_final
),
prices_with_previous_year AS (
    SELECT
        year,
        category_code,
        food_name,
        average_price,
        LAG(average_price) OVER (
            PARTITION BY category_code
            ORDER BY year
        ) AS previous_year_price
    FROM prices
),
price_changes AS (
    SELECT
        year,
        category_code,
        food_name,
        average_price,
        previous_year_price,
        ROUND(
            (
                (average_price - previous_year_price)
                / previous_year_price
            ) * 100,
            2
        ) AS price_growth_percent
    FROM prices_with_previous_year
)
SELECT
    category_code,
    food_name,
    ROUND(AVG(price_growth_percent), 2) AS average_price_growth_percent,
    COUNT(*) AS year_comparisons
FROM price_changes
WHERE price_growth_percent IS NOT NULL
GROUP BY
    category_code,
    food_name
ORDER BY average_price_growth_percent;


-- =============================================================
-- RESEARCH QUESTION 4
-- Is there a year in which food price growth was more than
-- 10 percentage points higher than wage growth?
-- =============================================================

WITH wages AS (
    SELECT DISTINCT
        year,
        industry_branch_code,
        average_wage
    FROM t_dmytro_syrvatka_project_sql_primary_final
),
wages_by_year AS (
    SELECT
        year,
        AVG(average_wage) AS average_wage
    FROM wages
    GROUP BY year
),
wages_growth AS (
    SELECT
        year,
        average_wage,
        LAG(average_wage) OVER (
            ORDER BY year
        ) AS previous_year_wage
    FROM wages_by_year
),
prices AS (
    SELECT DISTINCT
        year,
        category_code,
        average_price
    FROM t_dmytro_syrvatka_project_sql_primary_final
),
prices_by_year AS (
    SELECT
        year,
        AVG(average_price) AS average_price
    FROM prices
    GROUP BY year
),
prices_growth AS (
    SELECT
        year,
        average_price,
        LAG(average_price) OVER (
            ORDER BY year
        ) AS previous_year_price
    FROM prices_by_year
),
growth_comparison AS (
    SELECT
        wg.year,
        ROUND(
            (
                (wg.average_wage - wg.previous_year_wage)
                / wg.previous_year_wage
            ) * 100,
            2
        ) AS wage_growth_percent,
        ROUND(
            (
                (pg.average_price - pg.previous_year_price)
                / pg.previous_year_price
            ) * 100,
            2
        ) AS price_growth_percent
    FROM wages_growth wg
    JOIN prices_growth pg
        ON wg.year = pg.year
    WHERE wg.previous_year_wage IS NOT NULL
      AND pg.previous_year_price IS NOT NULL
)
SELECT
    year,
    wage_growth_percent,
    price_growth_percent,
    ROUND(price_growth_percent - wage_growth_percent, 2) AS difference_percent,
    CASE
        WHEN price_growth_percent - wage_growth_percent > 10 THEN 'YES'
        ELSE 'NO'
    END AS food_prices_grew_over_10pp_faster
FROM growth_comparison
ORDER BY difference_percent DESC;


-- =============================================================
-- RESEARCH QUESTION 5
-- Does stronger GDP growth correspond to stronger growth in wages
-- or food prices in the same or following year?
-- =============================================================

WITH gdp_data AS (
    SELECT
        year,
        gdp,
        LAG(gdp) OVER (
            ORDER BY year
        ) AS previous_year_gdp
    FROM t_dmytro_syrvatka_project_sql_secondary_final
    WHERE country = 'Czech Republic'
),
gdp_growth AS (
    SELECT
        year,
        ROUND(
            (
                (
                    (gdp - previous_year_gdp)
                    / previous_year_gdp
                ) * 100
            )::numeric,
            2
        ) AS gdp_growth_percent
    FROM gdp_data
),
wages AS (
    SELECT DISTINCT
        year,
        industry_branch_code,
        average_wage
    FROM t_dmytro_syrvatka_project_sql_primary_final
),
wages_by_year AS (
    SELECT
        year,
        AVG(average_wage) AS average_wage
    FROM wages
    GROUP BY year
),
wages_growth AS (
    SELECT
        year,
        ROUND(
            (
                (
                    average_wage
                    - LAG(average_wage) OVER (ORDER BY year)
                )
                / LAG(average_wage) OVER (ORDER BY year)
            ) * 100,
            2
        ) AS wage_growth_percent
    FROM wages_by_year
),
prices AS (
    SELECT DISTINCT
        year,
        category_code,
        average_price
    FROM t_dmytro_syrvatka_project_sql_primary_final
),
prices_by_year AS (
    SELECT
        year,
        AVG(average_price) AS average_price
    FROM prices
    GROUP BY year
),
prices_growth AS (
    SELECT
        year,
        ROUND(
            (
                (
                    average_price
                    - LAG(average_price) OVER (ORDER BY year)
                )
                / LAG(average_price) OVER (ORDER BY year)
            ) * 100,
            2
        ) AS price_growth_percent
    FROM prices_by_year
),
combined AS (
    SELECT
        g.year,
        g.gdp_growth_percent,
        w.wage_growth_percent,
        p.price_growth_percent
    FROM gdp_growth g
    JOIN wages_growth w
        ON g.year = w.year
    JOIN prices_growth p
        ON g.year = p.year
),
comparison AS (
    SELECT
        year,
        gdp_growth_percent,
        wage_growth_percent,
        price_growth_percent,
        LEAD(wage_growth_percent) OVER (
            ORDER BY year
        ) AS next_year_wage_growth_percent,
        LEAD(price_growth_percent) OVER (
            ORDER BY year
        ) AS next_year_price_growth_percent
    FROM combined
)
SELECT
    year,
    gdp_growth_percent,
    wage_growth_percent,
    price_growth_percent,
    next_year_wage_growth_percent,
    next_year_price_growth_percent
FROM comparison
WHERE gdp_growth_percent IS NOT NULL
ORDER BY year;
