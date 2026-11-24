-- 02_results.sql: outcomes by email group (R1), difference between groups (R2), how skewed spend is (R3).
-- Run from the repo folder: psql hillstrom -f sql/02_results.sql


-- R1: What happened in each email group in the two weeks after the emails?
SELECT
    segment,
    ROUND(SUM(visit) * 100.0 / COUNT(*), 2)             AS visit_rate,
    ROUND(SUM(conversion) * 100.0 / COUNT(*), 2)        AS conversion_rate,
    ROUND(AVG(spend), 2)                                AS spend_among_everyone,
    ROUND(AVG(spend) FILTER (WHERE conversion = 1), 2)  AS spend_among_buyers
FROM customers
GROUP BY segment;
-- Result: Visit rate 18.28% (men's), 15.14% (women's), 10.62% (none).
-- Conversion 1.25%, 0.88%, 0.57%. Spend per customer $1.42, $1.08, $0.65.
-- Differences are in R2.


-- R2: How much did each email change visits, conversion and spend, vs no email and vs each other?
WITH group_metrics AS (
    SELECT
        segment,
        SUM(visit) * 100.0 / COUNT(*)             AS visit_rate,
        SUM(conversion) * 100.0 / COUNT(*)        AS conversion_rate,
        AVG(spend)                                AS spend_among_everyone,
        AVG(spend) FILTER (WHERE conversion = 1)  AS spend_among_buyers
    FROM customers
    GROUP BY segment
), pairs (sort_order, comparison, group_a, group_b) AS (
    VALUES (1, 'Womens vs none',   'Womens E-Mail',   'No E-Mail'),
           (2, 'Mens vs none', 'Mens E-Mail', 'No E-Mail'),
           (3, 'Womens vs Mens', 'Womens E-Mail', 'Mens E-Mail')
)
SELECT
    p.comparison,
    ROUND(a.visit_rate - b.visit_rate, 2) AS visit_diff_pp,
    ROUND(a.conversion_rate - b.conversion_rate, 2) AS conversion_diff_pp,
    ROUND(a.spend_among_everyone - b.spend_among_everyone, 2) AS spend_among_everyone_diff,
    ROUND(a.spend_among_buyers - b.spend_among_buyers, 2) AS spend_among_buyers_diff
FROM pairs as p
JOIN group_metrics AS a ON a.segment = p.group_a
JOIN group_metrics AS b ON b.segment = p.group_b
ORDER BY p.sort_order;
-- Result: Both emails raised visits, conversion, and spend per customer vs no email.
-- The men's email did best: +7.66 pp visits, +0.68 pp conversion, +$0.77 per customer.
-- The women's email also did well: +4.52 pp visits, +0.31 pp conversion, +$0.42 per customer.
-- Spend among buyers had differences under $10. The extra revenue came mainly from more 
-- customers buying. Significance tests in notebooks/analysis.ipynb.


-- R3: How skewed is spend?
-- What % of customers spent $0?
SELECT ROUND(SUM(CASE WHEN spend = 0.0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS pct_spent_zero
FROM customers;

-- Among buyers, what are the median, 90th and 99th percentile of spend?
SELECT
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY spend) FILTER (WHERE conversion = 1)::numeric, 2) AS median_spend,
    ROUND(PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY spend) FILTER (WHERE conversion = 1)::numeric, 2) AS p90_spend,
    ROUND(PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY spend) FILTER (WHERE conversion = 1)::numeric, 2) AS p99_spend
FROM customers;
-- Result: 99.10% of customers spent nothing. Among the ~1% who bought, the median
-- was $80.80, but the 90th and 99th percentiles were $256.49 and $499.00: a few large
-- orders pull the average up (average per buyer ~$114-122 vs median $81). This skew
-- is why spend is checked with a bootstrap as well as a t-test.