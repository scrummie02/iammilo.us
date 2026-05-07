-- Gas Prices Database Schema
USE gas_prices;

-- Main table for daily gas price records
CREATE TABLE IF NOT EXISTS daily_prices (
    id INT AUTO_INCREMENT PRIMARY KEY,
    record_date DATE NOT NULL UNIQUE,
    region VARCHAR(100) NOT NULL,
    regular DECIMAL(5,3),
    midgrade DECIMAL(5,3),
    premium DECIMAL(5,3),
    diesel DECIMAL(5,3),
    source VARCHAR(50) DEFAULT 'AAA',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_date (record_date),
    INDEX idx_region (region)
);

-- Weekly aggregates view
CREATE OR REPLACE VIEW weekly_averages AS
SELECT 
    YEARWEEK(record_date, 1) AS year_week,
    DATE_FORMAT(MIN(record_date), '%Y-%m-%d') AS week_start,
    DATE_FORMAT(MAX(record_date), '%Y-%m-%d') AS week_end,
    region,
    AVG(regular) AS avg_regular,
    AVG(midgrade) AS avg_midgrade,
    AVG(premium) AS avg_premium,
    AVG(diesel) AS avg_diesel,
    MIN(regular) AS min_regular,
    MAX(regular) AS max_regular,
    COUNT(*) AS days_recorded
FROM daily_prices
WHERE regular IS NOT NULL
GROUP BY YEARWEEK(record_date, 1), region
ORDER BY week_start DESC;

-- Monthly aggregates view
CREATE OR REPLACE VIEW monthly_averages AS
SELECT 
    DATE_FORMAT(record_date, '%Y-%m') AS month,
    region,
    AVG(regular) AS avg_regular,
    AVG(midgrade) AS avg_midgrade,
    AVG(premium) AS avg_premium,
    AVG(diesel) AS avg_diesel,
    MIN(regular) AS min_regular,
    MAX(regular) AS max_regular,
    COUNT(*) AS days_recorded
FROM daily_prices
WHERE regular IS NOT NULL
GROUP BY DATE_FORMAT(record_date, '%Y-%m'), region
ORDER BY month DESC;

-- Trend analysis view (week-over-week changes)
CREATE OR REPLACE VIEW weekly_trends AS
SELECT 
    curr.week_start,
    curr.region,
    curr.avg_regular AS current_avg,
    prev.avg_regular AS previous_avg,
    (curr.avg_regular - prev.avg_regular) AS change_amount,
    ROUND(((curr.avg_regular - prev.avg_regular) / prev.avg_regular) * 100, 2) AS change_percent
FROM weekly_averages curr
LEFT JOIN weekly_averages prev 
    ON curr.year_week = prev.year_week + 1 
    AND curr.region = prev.region
WHERE curr.avg_regular IS NOT NULL AND prev.avg_regular IS NOT NULL
ORDER BY curr.week_start DESC;

-- Simple prediction table (7-day forecast based on linear trend)
CREATE TABLE IF NOT EXISTS predictions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    prediction_date DATE NOT NULL,
    predicted_date DATE NOT NULL,
    region VARCHAR(100) NOT NULL,
    predicted_regular DECIMAL(5,3),
    confidence_level VARCHAR(20) DEFAULT 'medium',
    model_used VARCHAR(50) DEFAULT 'linear_trend_7d',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_prediction_date (prediction_date),
    INDEX idx_predicted_date (predicted_date)
);
