-- Gas Prices Analysis Queries
USE gas_prices;

-- =====================================================
-- 1. CURRENT STATUS (as of latest date)
-- =====================================================
SELECT '=== CURRENT GAS PRICES ===' AS report;
SELECT 
    region,
    record_date,
    regular,
    midgrade,
    premium,
    diesel
FROM daily_prices 
WHERE record_date = (SELECT MAX(record_date) FROM daily_prices WHERE region = 'Washington DC (VA Only)')
AND region = 'Washington DC (VA Only)';

-- =====================================================
-- 2. WEEKLY AVERAGES WITH TRENDS
-- =====================================================
SELECT '=== WEEKLY AVERAGES ===' AS report;
SELECT * FROM weekly_averages WHERE region = 'Washington DC (VA Only)' LIMIT 10;

-- =====================================================
-- 3. WEEK-OVER-WEEK CHANGE ANALYSIS
-- =====================================================
SELECT '=== WEEKLY TRENDS (WoW Change) ===' AS report;
SELECT 
    week_start,
    current_avg,
    previous_avg,
    change_amount,
    CONCAT(CHANGE_PERCENT, '%') AS change_percent
FROM weekly_trends 
WHERE region = 'Washington DC (VA Only)'
ORDER BY week_start DESC 
LIMIT 5;

-- =====================================================
-- 4. MONTHLY AVERAGES
-- =====================================================
SELECT '=== MONTHLY AVERAGES ===' AS report;
SELECT * FROM monthly_averages WHERE region = 'Washington DC (VA Only)' LIMIT 12;

-- =====================================================
-- 5. 7-DAY MOVING AVERAGE
-- =====================================================
SELECT '=== 7-DAY MOVING AVERAGE ===' AS report;
SELECT 
    record_date,
    regular,
    ROUND(AVG(regular) OVER (ORDER BY record_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 3) AS moving_avg_7d
FROM daily_prices
WHERE region = 'Washington DC (VA Only)'
ORDER BY record_date DESC
LIMIT 14;

-- =====================================================
-- 6. PERCENTAGE CHANGE CALCULATIONS
-- =====================================================
SELECT '=== PERCENTAGE CHANGES ===' AS report;
SELECT 
    'vs Yesterday' AS comparison,
    ROUND(((curr.regular - prev.regular) / prev.regular) * 100, 2) AS percent_change
FROM daily_prices curr
JOIN daily_prices prev ON curr.record_date = DATE_ADD(prev.record_date, INTERVAL 1 DAY)
WHERE curr.region = 'Washington DC (VA Only)' 
AND prev.region = 'Washington DC (VA Only)'
AND curr.record_date = (SELECT MAX(record_date) FROM daily_prices WHERE region = 'Washington DC (VA Only)')
UNION ALL
SELECT 
    'vs Week Ago',
    ROUND(((curr.regular - prev.regular) / prev.regular) * 100, 2)
FROM daily_prices curr
JOIN daily_prices prev ON curr.record_date = DATE_ADD(prev.record_date, INTERVAL 7 DAY)
WHERE curr.region = 'Washington DC (VA Only)' 
AND prev.region = 'Washington DC (VA Only)'
AND curr.record_date = (SELECT MAX(record_date) FROM daily_prices WHERE region = 'Washington DC (VA Only)')
UNION ALL
SELECT 
    'vs Month Ago',
    ROUND(((curr.regular - prev.regular) / prev.regular) * 100, 2)
FROM daily_prices curr
JOIN daily_prices prev ON curr.record_date = DATE_ADD(prev.record_date, INTERVAL 30 DAY)
WHERE curr.region = 'Washington DC (VA Only)' 
AND prev.region = 'Washington DC (VA Only)'
AND curr.record_date = (SELECT MAX(record_date) FROM daily_prices WHERE region = 'Washington DC (VA Only)')
UNION ALL
SELECT 
    'vs Year Ago',
    ROUND(((curr.regular - prev.regular) / prev.regular) * 100, 2)
FROM daily_prices curr
JOIN daily_prices prev ON curr.record_date = DATE_ADD(prev.record_date, INTERVAL 365 DAY)
WHERE curr.region = 'Washington DC (VA Only)' 
AND prev.region = 'Washington DC (VA Only)'
AND curr.record_date = (SELECT MAX(record_date) FROM daily_prices WHERE region = 'Washington DC (VA Only)');

-- =====================================================
-- 7. LINEAR TREND PREDICTION (Next 7 Days)
-- Based on average daily change over last 14 days
-- =====================================================
SELECT '=== 7-DAY PRICE PREDICTION ===' AS report;

-- Calculate trend and generate predictions
WITH trend_calc AS (
    SELECT 
        AVG(regular) AS avg_price,
        COUNT(*) AS days_count,
        (MAX(regular) - MIN(regular)) / COUNT(*) AS daily_change_rate
    FROM daily_prices
    WHERE region = 'Washington DC (VA Only)'
    AND record_date >= DATE_SUB((SELECT MAX(record_date) FROM daily_prices), INTERVAL 14 DAY)
),
latest_price AS (
    SELECT regular AS latest_regular, record_date AS latest_date
    FROM daily_prices
    WHERE region = 'Washington DC (VA Only)'
    ORDER BY record_date DESC
    LIMIT 1
)
SELECT 
    DATE_ADD(l.latest_date, INTERVAL n DAY) AS predicted_date,
    ROUND(l.latest_regular + (t.daily_change_rate * n), 3) AS predicted_price,
    'linear_trend_14d' AS model
FROM latest_price l
CROSS JOIN trend_calc t
CROSS JOIN (SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7) nums
ORDER BY predicted_date;

-- =====================================================
-- 8. INSERT PREDICTIONS INTO TABLE
-- =====================================================
INSERT INTO predictions (prediction_date, predicted_date, region, predicted_regular, confidence_level, model_used)
WITH trend_calc AS (
    SELECT 
        AVG(regular) AS avg_price,
        COUNT(*) AS days_count,
        (MAX(regular) - MIN(regular)) / COUNT(*) AS daily_change_rate
    FROM daily_prices
    WHERE region = 'Washington DC (VA Only)'
    AND record_date >= DATE_SUB((SELECT MAX(record_date) FROM daily_prices), INTERVAL 14 DAY)
),
latest_price AS (
    SELECT regular AS latest_regular, record_date AS latest_date
    FROM daily_prices
    WHERE region = 'Washington DC (VA Only)'
    ORDER BY record_date DESC
    LIMIT 1
)
SELECT 
    (SELECT MAX(record_date) FROM daily_prices) AS prediction_date,
    DATE_ADD(l.latest_date, INTERVAL n DAY) AS predicted_date,
    'Washington DC (VA Only)' AS region,
    ROUND(l.latest_regular + (t.daily_change_rate * n), 3) AS predicted_regular,
    'medium' AS confidence_level,
    'linear_trend_14d' AS model_used
FROM latest_price l
CROSS JOIN trend_calc t
CROSS JOIN (SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7) nums
ON DUPLICATE KEY UPDATE predicted_regular = VALUES(predicted_regular);

-- =====================================================
-- 9. SHOW GENERATED PREDICTIONS
-- =====================================================
SELECT '=== STORED PREDICTIONS ===' AS report;
SELECT * FROM predictions 
WHERE region = 'Washington DC (VA Only)'
ORDER BY predicted_date DESC 
LIMIT 7;

-- =====================================================
-- 10. PRICE VOLATILITY ANALYSIS
-- =====================================================
SELECT '=== VOLATILITY ANALYSIS (Last 30 Days) ===' AS report;
SELECT 
    region,
    COUNT(*) AS days,
    ROUND(AVG(regular), 3) AS average,
    ROUND(MIN(regular), 3) AS minimum,
    ROUND(MAX(regular), 3) AS maximum,
    ROUND(MAX(regular) - MIN(regular), 3) AS range,
    ROUND(STDDEV(regular), 3) AS std_deviation,
    ROUND((MAX(regular) - MIN(regular)) / AVG(regular) * 100, 2) AS volatility_percent
FROM daily_prices
WHERE region = 'Washington DC (VA Only)'
AND record_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY region;
