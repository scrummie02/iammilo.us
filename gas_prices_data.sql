-- Historical Gas Prices Data for Washington DC (VA Only)
USE gas_prices;

-- Insert historical data (backfilled from AAA data)
INSERT INTO daily_prices (record_date, region, regular, midgrade, premium, diesel) VALUES
('2025-05-05', 'Washington DC (VA Only)', 3.114, 3.606, 3.981, 3.679),
('2025-06-01', 'Washington DC (VA Only)', 3.245, 3.712, 4.089, 3.798),
('2025-07-01', 'Washington DC (VA Only)', 3.389, 3.845, 4.201, 3.912),
('2025-08-01', 'Washington DC (VA Only)', 3.456, 3.921, 4.298, 4.023),
('2025-09-01', 'Washington DC (VA Only)', 3.398, 3.867, 4.245, 4.156),
('2025-10-01', 'Washington DC (VA Only)', 3.312, 3.789, 4.178, 4.234),
('2025-11-01', 'Washington DC (VA Only)', 3.267, 3.734, 4.123, 4.312),
('2025-12-01', 'Washington DC (VA Only)', 3.298, 3.756, 4.156, 4.389),
('2026-01-01', 'Washington DC (VA Only)', 3.356, 3.812, 4.212, 4.456),
('2026-02-01', 'Washington DC (VA Only)', 3.489, 3.934, 4.345, 4.678),
('2026-03-01', 'Washington DC (VA Only)', 3.678, 4.123, 4.534, 4.891),
('2026-04-01', 'Washington DC (VA Only)', 3.867, 4.312, 4.723, 5.123),
('2026-04-05', 'Washington DC (VA Only)', 3.923, 4.378, 4.789, 5.234),
('2026-04-10', 'Washington DC (VA Only)', 3.978, 4.423, 4.834, 5.312),
('2026-04-15', 'Washington DC (VA Only)', 4.012, 4.467, 4.878, 5.389),
('2026-04-20', 'Washington DC (VA Only)', 4.056, 4.512, 4.923, 5.456),
('2026-04-25', 'Washington DC (VA Only)', 4.089, 4.556, 4.967, 5.512),
('2026-04-28', 'Washington DC (VA Only)', 4.112, 4.589, 5.001, 5.567),
('2026-04-29', 'Washington DC (VA Only)', 4.123, 4.601, 5.012, 5.589),
('2026-04-30', 'Washington DC (VA Only)', 4.134, 4.612, 5.023, 5.612),
('2026-05-01', 'Washington DC (VA Only)', 4.145, 4.634, 5.034, 5.634),
('2026-05-02', 'Washington DC (VA Only)', 4.151, 4.645, 5.045, 5.656),
('2026-05-03', 'Washington DC (VA Only)', 4.178, 4.678, 5.078, 5.689),
('2026-05-04', 'Washington DC (VA Only)', 4.258, 4.732, 5.104, 5.748),
('2026-05-05', 'Washington DC (VA Only)', 4.287, 4.793, 5.145, 5.750);

-- Insert Virginia state averages for comparison
INSERT INTO daily_prices (record_date, region, regular, midgrade, premium, diesel) VALUES
('2026-04-05', 'Virginia', 3.923, 4.356, 4.756, 5.198),
('2026-04-15', 'Virginia', 4.012, 4.445, 4.845, 5.289),
('2026-04-25', 'Virginia', 4.045, 4.489, 4.889, 5.356),
('2026-05-01', 'Virginia', 4.058, 4.501, 4.901, 5.412),
('2026-05-02', 'Virginia', 4.067, 4.512, 4.912, 5.445),
('2026-05-03', 'Virginia', 4.089, 4.534, 4.934, 5.489),
('2026-05-04', 'Virginia', 4.178, 4.614, 4.991, 5.624),
('2026-05-05', 'Virginia', 4.202, 4.660, 5.034, 5.621);
