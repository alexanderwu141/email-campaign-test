-- 00_load.sql : create the customers table and load data/raw/hillstrom.csv.
-- Run from the repo folder:  psql hillstrom -v ON_ERROR_STOP=1 -f sql/00_load.sql

DROP TABLE IF EXISTS customers;
CREATE TABLE customers(
    recency                 integer, 
    history_segment         text, 
    history                 numeric, 
    mens                    integer, 
    womens                  integer, 
    zip_code                text,
    newbie                  integer, 
    channel                 text, 
    segment                 text, 
    visit                   integer, 
    conversion              integer, 
    spend                   numeric
);
\copy customers FROM 'data/raw/hillstrom.csv' WITH (FORMAT csv, HEADER true)
SELECT COUNT(*) FROM customers;