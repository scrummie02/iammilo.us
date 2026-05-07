# Gas Prices Database - Virginia

MySQL container tracking weekly gas prices in Virginia (Washington DC metro area) with trend analysis and predictions.

## Quick Start

**View today's report:**
```bash
./gas_prices_daily_report.sh
```

**Database connection:**
```bash
docker exec -it gas-prices-db mysql -u root -pgasprices2026 gas_prices
```

**Direct query example:**
```bash
docker exec gas-prices-db mysql -u root -pgasprices2026 gas_prices -e "SELECT * FROM daily_prices ORDER BY record_date DESC LIMIT 5;"
```

## Database Schema

### Tables

**daily_prices** - Main price records
- `record_date` - Date of price record
- `region` - Geographic area (e.g., "Washington DC (VA Only)")
- `regular`, `midgrade`, `premium`, `diesel` - Fuel prices per gallon
- `source` - Data source (default: AAA)

**predictions** - Generated forecasts
- `predicted_date` - Date being predicted
- `predicted_regular` - Forecasted price
- `confidence_level` - low/medium/high
- `model_used` - Prediction algorithm

### Views

**weekly_averages** - Aggregated weekly data
**weekly_trends** - Week-over-week changes
**monthly_averages** - Monthly aggregations

## Current Status (May 5, 2026)

| Metric | Value |
|--------|-------|
| Current Price | $4.287 |
| vs Yesterday | +0.68% |
| vs Week Ago | +4.26% |
| vs Month Ago | +9.28% |
| vs Year Ago | +37.67% |

## 7-Day Prediction

Based on 14-day linear trend:

| Date | Predicted Price |
|------|-----------------|
| May 6 | $4.316 |
| May 7 | $4.345 |
| May 8 | $4.375 |
| May 9 | $4.404 |
| May 10 | $4.433 |
| May 11 | $4.462 |
| May 12 | $4.491 |

**Trend:** Rising ~2.9¢/day

## Automation

### Daily Report Cron Job

Add to crontab (`crontab -e`):
```cron
# Daily gas prices report at 8 AM
0 8 * * * /home/dain/.openclaw/workspace/gas_prices_daily_report.sh >> /home/dain/.openclaw/workspace/logs/gas_prices.log 2>&1
```

### Data Update Workflow

1. **Manual** (current): Fetch from AAA website, insert via SQL
2. **Automated** (future): Python script with BeautifulSoup to scrape AAA daily

Example manual insert:
```sql
INSERT INTO daily_prices (record_date, region, regular, midgrade, premium, diesel)
VALUES ('2026-05-06', 'Washington DC (VA Only)', 4.31, 4.82, 5.17, 5.78);
```

## Analysis Queries

### Week-over-week change
```sql
SELECT * FROM weekly_trends 
WHERE region = 'Washington DC (VA Only)' 
ORDER BY week_start DESC LIMIT 5;
```

### 7-day moving average
```sql
SELECT record_date, regular,
    AVG(regular) OVER (ORDER BY record_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS ma_7d
FROM daily_prices WHERE region = 'Washington DC (VA Only)';
```

### Volatility (30-day)
```sql
SELECT 
    ROUND(STDDEV(regular), 3) AS std_dev,
    ROUND((MAX(regular) - MIN(regular)) / AVG(regular) * 100, 2) AS volatility_pct
FROM daily_prices 
WHERE record_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);
```

## Files

- `gas_prices_schema.sql` - Database schema
- `gas_prices_data.sql` - Historical data seed
- `gas_prices_queries.sql` - Analysis queries
- `gas_prices_daily_report.sh` - Daily report script
- `gas_prices_fetch.sh` - Data fetcher (template)
- `gas_prices_chart.html` - Interactive chart

## Container Management

**Start:** `docker start gas-prices-db`
**Stop:** `docker stop gas-prices-db`
**Restart:** `docker restart gas-prices-db`
**Logs:** `docker logs gas-prices-db`

**Backup:**
```bash
docker exec gas-prices-db mysqldump -u root -pgasprices2026 gas_prices > backup_$(date +%Y%m%d).sql
```

**Restore:**
```bash
docker exec -i gas-prices-db mysql -u root -pgasprices2026 gas_prices < backup_YYYYMMDD.sql
```

## Data Sources

- **Primary:** AAA Fuel Prices (gasprices.aaa.com)
- **Region:** Washington DC (VA Only) - includes Alexandria, Arlington, Fairfax
- **Update Frequency:** Daily

## Prediction Model

Current model: **Linear Trend (14-day)**
- Calculates average daily change over last 14 days
- Projects forward 7 days
- Confidence: Medium (short-term trends more reliable)

Future enhancements:
- Moving average crossover signals
- Seasonal adjustment factors
- External factors (crude oil prices, refinery capacity)
