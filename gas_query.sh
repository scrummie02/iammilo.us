#!/bin/bash
# Quick gas prices query tool

DB_CONTAINER="gas-prices-db"
DB_USER="root"
DB_PASS="gasprices2026"
DB_NAME="gas_prices"

QUERY="$1"

case "$QUERY" in
    current|today)
        docker exec $DB_CONTAINER mysql -u $DB_USER -p$DB_PASS $DB_NAME -e "
            SELECT record_date AS Date, regular AS Regular, midgrade AS Midgrade, premium AS Premium, diesel AS Diesel
            FROM daily_prices 
            WHERE region = 'Washington DC (VA Only)' 
            ORDER BY record_date DESC LIMIT 1;"
        ;;
    trend|trends)
        docker exec $DB_CONTAINER mysql -u $DB_USER -p$DB_PASS $DB_NAME -e "
            SELECT record_date AS Date, regular AS Price,
                ROUND(regular - LAG(regular, 1) OVER (ORDER BY record_date), 3) AS Change
            FROM daily_prices 
            WHERE region = 'Washington DC (VA Only)' 
            ORDER BY record_date DESC LIMIT 10;"
        ;;
    predict|prediction)
        docker exec $DB_CONTAINER mysql -u $DB_USER -p$DB_PASS $DB_NAME -e "
            SELECT predicted_date AS Date, predicted_regular AS Predicted_Price, confidence_level AS Confidence
            FROM predictions 
            WHERE region = 'Washington DC (VA Only)' 
            ORDER BY predicted_date DESC LIMIT 7;"
        ;;
    history|hist)
        docker exec $DB_CONTAINER mysql -u $DB_USER -p$DB_PASS $DB_NAME -e "
            SELECT record_date AS Date, regular AS Price FROM daily_prices 
            WHERE region = 'Washington DC (VA Only)' 
            ORDER BY record_date DESC LIMIT 30;"
        ;;
    stats)
        docker exec $DB_CONTAINER mysql -u $DB_USER -p$DB_PASS $DB_NAME -e "
            SELECT 
                COUNT(*) AS Records,
                MIN(record_date) AS First_Date,
                MAX(record_date) AS Last_Date,
                ROUND(AVG(regular), 3) AS Avg_Price,
                ROUND(MIN(regular), 3) AS Min_Price,
                ROUND(MAX(regular), 3) AS Max_Price
            FROM daily_prices 
            WHERE region = 'Washington DC (VA Only)';"
        ;;
    *)
        echo "Gas Prices Query Tool"
        echo "Usage: ./gas_query.sh <command>"
        echo ""
        echo "Commands:"
        echo "  current   - Today's prices"
        echo "  trend     - Last 10 days with changes"
        echo "  predict   - 7-day forecast"
        echo "  history   - Last 30 days"
        echo "  stats     - Database statistics"
        echo ""
        echo "Examples:"
        echo "  ./gas_query.sh current"
        echo "  ./gas_query.sh predict"
        ;;
esac
