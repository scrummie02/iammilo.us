#!/bin/bash
# Daily Gas Prices Report Script
# Runs queries against the gas_prices MySQL database

DB_CONTAINER="gas-prices-db"
DB_USER="root"
DB_PASS="gasprices2026"
DB_NAME="gas_prices"

run_query() {
    docker exec $DB_CONTAINER mysql -u $DB_USER -p$DB_PASS $DB_NAME -N -e "$1"
}

echo "╔════════════════════════════════════════════════════════╗"
echo "║         DAILY GAS PRICES REPORT - VIRGINIA            ║"
echo "║              Washington DC (VA Only)                   ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Current Price
CURRENT=$(run_query "SELECT CONCAT('$', regular, ' as of ', record_date) FROM daily_prices WHERE region = 'Washington DC (VA Only)' ORDER BY record_date DESC LIMIT 1;")
echo "📍 Current Price: $CURRENT"
echo ""

# Percentage Changes
echo "📊 Percentage Changes:"
echo "─────────────────────────────────────"
run_query "
SELECT CONCAT('  vs Yesterday: ', IF(((curr.regular - prev.regular) / prev.regular) * 100 > 0, '⬆ +', '⬇ '), ROUND(ABS(((curr.regular - prev.regular) / prev.regular) * 100), 2), '%')
FROM daily_prices curr 
JOIN daily_prices prev ON curr.record_date = DATE_ADD(prev.record_date, INTERVAL 1 DAY)
WHERE curr.region = 'Washington DC (VA Only)' 
AND curr.record_date = (SELECT MAX(record_date) FROM daily_prices WHERE region = 'Washington DC (VA Only)');
"

run_query "
SELECT CONCAT('  vs Week Ago:  ', IF(((curr.regular - prev.regular) / prev.regular) * 100 > 0, '⬆ +', '⬇ '), ROUND(ABS(((curr.regular - prev.regular) / prev.regular) * 100), 2), '%')
FROM daily_prices curr 
JOIN daily_prices prev ON curr.record_date = DATE_ADD(prev.record_date, INTERVAL 7 DAY)
WHERE curr.region = 'Washington DC (VA Only)' 
AND curr.record_date = (SELECT MAX(record_date) FROM daily_prices WHERE region = 'Washington DC (VA Only)');
"

run_query "
SELECT CONCAT('  vs Month Ago: ', IF(((curr.regular - prev.regular) / prev.regular) * 100 > 0, '⬆ +', '⬇ '), ROUND(ABS(((curr.regular - prev.regular) / prev.regular) * 100), 2), '%')
FROM daily_prices curr 
JOIN daily_prices prev ON curr.record_date = DATE_ADD(prev.record_date, INTERVAL 30 DAY)
WHERE curr.region = 'Washington DC (VA Only)' 
AND curr.record_date = (SELECT MAX(record_date) FROM daily_prices WHERE region = 'Washington DC (VA Only)');
"

run_query "
SELECT CONCAT('  vs Year Ago:  ', IF(((curr.regular - prev.regular) / prev.regular) * 100 > 0, '⬆ +', '⬇ '), ROUND(ABS(((curr.regular - prev.regular) / prev.regular) * 100), 2), '%')
FROM daily_prices curr 
JOIN daily_prices prev ON curr.record_date = DATE_ADD(prev.record_date, INTERVAL 365 DAY)
WHERE curr.region = 'Washington DC (VA Only)' 
AND curr.record_date = (SELECT MAX(record_date) FROM daily_prices WHERE region = 'Washington DC (VA Only)');
"

echo ""
echo "📈 7-Day Price Prediction (Linear Trend):"
echo "─────────────────────────────────────"

# Generate and display predictions
run_query "
WITH trend_calc AS (
    SELECT 
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
SELECT CONCAT('  ', DATE_ADD(l.latest_date, INTERVAL n DAY), ': $', ROUND(l.latest_regular + (t.daily_change_rate * n), 3))
FROM latest_price l
CROSS JOIN trend_calc t
CROSS JOIN (SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7) nums
ORDER BY n;
"

echo ""
echo "─────────────────────────────────────"
echo "Report generated: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Data source: AAA Fuel Prices"
