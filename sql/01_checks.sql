-- 01_checks.sql : health checks before looking at results.
-- Run from the repo folder:  psql hillstrom -f sql/01_checks.sql

-- Are there any missing values?
SELECT 
    COUNT(*)                    AS total_rows, 
    COUNT(recency)              AS recency_rows, 
    COUNT(history_segment)      AS history_segment_rows, 
    COUNT(history)              AS history_rows, 
    COUNT(mens)                 AS mens_rows, 
    COUNT(womens)               AS womens_rows, 
    COUNT(zip_code)             AS zip_code_rows, 
    COUNT(newbie)               AS newbie_rows, 
    COUNT(channel)              AS channel_rows, 
    COUNT(segment)              AS segment_rows, 
    COUNT(visit)                AS visit_rows, 
    COUNT(conversion)           AS conversion_rows, 
    COUNT(spend)                AS spend_rows
FROM customers;
-- Result: 64,000 rows, every column has 64,000 values so no missing values.


-- Are the group sizes consistent with an equal three-way split? 
SELECT 
    segment,
    COUNT(*) AS customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM customers
GROUP BY segment;
-- Result: 21,387 / 21,307 / 21,306 customers (33.42% / 33.29% / 33.29%),
-- very close to an equal split. Chi-square test in notebooks/analysis.ipynb.


-- Are the groups alike in every way before the emails are sent?
SELECT
    segment,
    ROUND(AVG(history), 2)                                                                   AS avg_history,
    ROUND(AVG(recency), 2)                                                                   AS avg_recency,
    ROUND(AVG(newbie) * 100.0, 2)                                                            AS pct_newbie,
    ROUND(AVG(mens) * 100.0, 2)                                                              AS pct_mens,
    ROUND(AVG(womens) * 100.0, 2)                                                            AS pct_womens,
    ROUND(SUM(CASE WHEN channel = 'Phone' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)          AS pct_phone,
    ROUND(SUM(CASE WHEN channel = 'Web' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)            AS pct_web,
    ROUND(SUM(CASE WHEN channel = 'Multichannel' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)   AS pct_multichannel,
    ROUND(SUM(CASE WHEN zip_code = 'Urban' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)         AS pct_urban,
    ROUND(SUM(CASE WHEN zip_code = 'Surburban' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)     AS pct_suburban,
    ROUND(SUM(CASE WHEN zip_code = 'Rural' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)         AS pct_rural
FROM customers
GROUP BY segment;
-- Result: all three groups are nearly identical before the emails
-- (e.g. average past spend $X / $Y / $Z; X% / Y% / Z% new customers).
-- Standardized mean differences in notebooks/analysis.ipynb.


-- Do the outcomes make sense?
SELECT
    COUNT(*) FILTER (WHERE conversion = 1 AND visit = 0)    AS bought_without_visit,
    COUNT(*) FILTER (WHERE conversion = 0 AND spend > 0)    AS spend_without_purchase,
    COUNT(*) FILTER (WHERE conversion = 1 AND spend = 0)    AS purchase_without_spend,
    COUNT(*) FILTER (WHERE spend < 0)                       AS negative_spend
FROM customers;
-- Result: all four counts are 0, so the outcome columns are consistent.