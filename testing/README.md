# PredictHealth Load Testing

Comprehensive load testing suite for PredictHealth microservices using Locust.

## Quick Start

### Run Individual Tests

```powershell
# Smoke test (2 min)
.\testing\test_smoke.ps1

# Baseline test (10 min)
.\testing\test_baseline.ps1

# Read-heavy test (15 min)
.\testing\test_readheavy.ps1

# Write-heavy test (10 min)
.\testing\test_writeheavy.ps1

# Spike test (5 min)
.\testing\test_spike.ps1

# Ramp-up test (10 min)
.\testing\test_rampup.ps1

# Ramp-down test (10 min)
.\testing\test_rampdown.ps1

# CSV test (10 min)
.\testing\test_csv.ps1

# Soak test (1 hour)
.\testing\test_soak.ps1

# Breakpoint test (20 min)
.\testing\test_breakpoint.ps1
```

### Run All Tests

```powershell
# Run all tests
.\testing\run_all_tests.ps1

# Skip long-running tests
.\testing\run_all_tests.ps1 -SkipSoak -SkipBreakpoint
```

## Test Results

All test results are saved in `testing/load_test_results_TIMESTAMP/` with:
- `report.html` - Interactive graphs and charts
- `stats.csv` - Raw statistics
- `stats_history.csv` - Time-series data
- `failures.csv` - Failed requests
- `exceptions.csv` - Exceptions encountered

## Test Scenarios

| Test | Users | Duration | Purpose |
|------|-------|----------|---------|
| Smoke | 10 | 2m | Quick verification |
| Baseline | 50 | 10m | Performance baseline |
| Read-Heavy | 100 | 15m | 80% reads, 20% writes |
| Write-Heavy | 50 | 10m | 80% writes, 20% reads |
| Spike | 200 | 5m | Sudden traffic burst |
| Ramp-Up | 100 | 10m | Gradual increase |
| Ramp-Down | 100 | 10m | Gradual decrease |
| CSV | 200 | 10m | All database users |
| Soak | 100 | 1h | Memory leak detection |
| Breakpoint | 500 | 20m | Find system limits |

## Files

- `locustfile.py` - Test definitions
- `users.csv` - Test user credentials (200 users)
- `test_*.ps1` - Individual test scripts
- `run_all_tests.ps1` - Run all tests
- `LOAD_TESTING.md` - Detailed documentation

## Requirements

- Python with Locust installed: `pip install locust`
- All 8 microservices running on ports 8001-8011
- PostgreSQL with test data loaded

## Viewing Results

1. Run a test
2. Open the generated `report.html` in your browser
3. View interactive graphs, response times, and failure rates
