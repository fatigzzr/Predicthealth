# Automated Load Testing Suite

## Quick Start

### Run All Tests (Automated)
```powershell
cd D:\Repos\Predicthealth
.\services\run_all_tests.ps1
```

This will:
- ✅ Verify all 8 microservices are running
- ✅ Run all 10 load test scenarios sequentially
- ✅ Generate HTML reports for each test
- ✅ Export CSV data for analysis
- ✅ Create comprehensive summary report

**Total Runtime:** ~1.5-2 hours (with Soak test)

---

## Options

### Skip Long-Running Tests
```powershell
# Skip Soak test (saves 1 hour)
.\services\run_all_tests.ps1 -SkipSoak

# Skip Breakpoint test (unpredictable duration)
.\services\run_all_tests.ps1 -SkipBreakpoint

# Skip both
.\services\run_all_tests.ps1 -SkipSoak -SkipBreakpoint
```

### Custom Host
```powershell
# Test remote server
.\services\run_all_tests.ps1 -Host "http://192.168.1.100"
```

---

## Test Sequence

The script runs tests in this order:

1. **Smoke Test** (2 min) - Quick verification
2. **Baseline Test** (10 min) - Performance baseline
3. **Read-Heavy Test** (15 min) - Typical usage (80% reads)
4. **Write-Heavy Test** (10 min) - Database write capacity
5. **Spike Test** (5 min) - Sudden traffic burst
6. **Ramp-Up Test** (10 min) - Gradual load increase
7. **Ramp-Down Test** (10 min) - Gradual load decrease
8. **CSV Test** (10 min) - All 200 DB users
9. **Soak Test** (1 hour) - Memory leak detection *(optional)*
10. **Breakpoint Test** (variable) - Find capacity limits *(optional)*

**10-second pause between tests** to let services stabilize.

---

## Output Structure

Results saved to timestamped folder:
```
load_test_results_20251123_143022/
├── SUMMARY.md                           # Overall summary
├── smoketest.html                       # HTML report
├── smoketest_stats.csv                  # Statistics
├── smoketest_stats_history.csv          # Time-series data
├── smoketest_failures.csv               # Error log
├── smoketest.log                        # Test output
├── baselinetest.html
├── baselinetest_stats.csv
├── baselinetest_stats_history.csv
├── baselinetest_failures.csv
├── baselinetest.log
├── readheavytest.html
├── ... (same pattern for each test)
└── breakpointtest.log
```

---

## View Results

### Open Summary
```powershell
notepad load_test_results_*/SUMMARY.md
```

### View HTML Reports (Interactive)
```powershell
# Baseline report
start load_test_results_*/baselinetest.html

# All reports
Get-ChildItem load_test_results_*/*.html | ForEach-Object { start $_.FullName }
```

### Analyze CSV Data
```powershell
# View statistics
Import-Csv load_test_results_*/baselinetest_stats.csv | Format-Table

# Filter failures only
Import-Csv load_test_results_*/baselinetest_failures.csv | Format-Table

# Response time over time
Import-Csv load_test_results_*/baselinetest_stats_history.csv | Select-Object Timestamp, 'Total Request Count', 'Total Average Response Time'
```

---

## Prerequisites

### 1. Start All Services
Before running tests, ensure all 8 microservices are running:

```powershell
# Use background startup (PRODUCTION_WIN.md)
Start-Process powershell -ArgumentList "-NoExit", "-Command", "uvicorn services.auth_service.main:app --host 0.0.0.0 --port 8001 --workers 4"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "uvicorn services.register_service.main:app --host 0.0.0.0 --port 8002 --workers 2"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "uvicorn services.patient_service.main:app --host 0.0.0.0 --port 8003 --workers 2"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "uvicorn services.health_service.main:app --host 0.0.0.0 --port 8004 --workers 2"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "uvicorn services.diabetes_service.main:app --host 0.0.0.0 --port 8008 --workers 4"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "uvicorn services.hypertension_service.main:app --host 0.0.0.0 --port 8009 --workers 4"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "uvicorn services.data_service.main:app --host 0.0.0.0 --port 8010 --workers 4"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "uvicorn services.recommendations_service.main:app --host 0.0.0.0 --port 8011 --workers 2"
```

**Verify services:**
```powershell
netstat -ano | findstr "8001 8002 8003 8004 8008 8009 8010 8011"
```

### 2. Database Setup
```powershell
# Ensure PostgreSQL is running with test data
psql -U postgres -d predicthealth -f "Base de Datos/init.sql"
```

### 3. Redis Running
```powershell
# Start Redis (for JWT validation)
redis-server
```

---

## Interpreting Results

### HTML Report Sections

**Statistics Tab:**
- Request count per endpoint
- Failure rate (should be <1%)
- Response times (p50, p95, p99)
- Requests per second

**Charts Tab:**
- Total requests per second over time
- Response time distribution
- Number of users over time

**Failures Tab:**
- Error messages and stack traces
- Failure count by endpoint

**Download Data:**
- Export results as CSV for further analysis

### Key Metrics to Monitor

#### ✅ Good Performance
- **Failure rate**: <1%
- **Response time p95**: <500ms (most endpoints)
- **Response time p95**: <200ms (ML predictions)
- **Auth login**: >500 req/sec
- **Patient GET**: >1000 req/sec

#### ⚠️ Warning Signs
- **Failure rate**: 1-5%
- **Response time p95**: 500-1000ms
- **Sporadic 500 errors**

#### 🚨 Critical Issues
- **Failure rate**: >10%
- **Response time p99**: >5000ms
- **Connection timeouts**
- **Services crashing during test**

---

## Troubleshooting

### Script Fails Immediately
```powershell
# Check execution policy
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Run with explicit policy
powershell -ExecutionPolicy Bypass -File services/run_all_tests.ps1
```

### Services Not Detected
```powershell
# Manually verify each port
Test-NetConnection -ComputerName localhost -Port 8001
Test-NetConnection -ComputerName localhost -Port 8002
# ... etc
```

### High Failure Rate (>10%)
- **Too many workers**: Reduce worker count in service startup
- **Database connections**: Check PostgreSQL max_connections
- **Redis down**: Restart Redis server
- **Out of memory**: Monitor with Task Manager

### Tests Timing Out
- **Increase timeout**: Edit locustfile.py, add `connection_timeout` parameter
- **Reduce concurrent users**: Lower `--users` count in script
- **Check network**: Ping localhost, check firewall

---

## Customization

### Modify Test Configuration
Edit `run_all_tests.ps1`:

```powershell
# Change test duration
Runtime = "5m"  # Instead of 10m

# Change user count
Users = 25  # Instead of 50

# Add custom test
@{
    Name = "11. Custom Test"
    Class = "CustomTest"
    Users = 150
    SpawnRate = 15
    Runtime = "20m"
    Description = "Your custom scenario"
}
```

### Run Subset of Tests
```powershell
# Edit $tests array in script, comment out unwanted tests
# Or create custom script with only desired tests
```

---

## Best Practices

### Initial Testing
1. Run with `-SkipSoak -SkipBreakpoint` first (~45 min)
2. Review Baseline and Read-Heavy reports
3. Fix any failures before proceeding

### Regular Testing
1. Run weekly with `-SkipSoak -SkipBreakpoint`
2. Compare results to previous runs
3. Track performance trends over time

### Pre-Production
1. Run full suite (including Soak) overnight
2. Run Breakpoint test to find capacity limits
3. Archive results for documentation

### Performance Regression Detection
```powershell
# Compare two test runs
$old = Import-Csv load_test_results_OLD/baselinetest_stats.csv
$new = Import-Csv load_test_results_NEW/baselinetest_stats.csv

# Compare average response times
$old | Select Name, 'Average Response Time'
$new | Select Name, 'Average Response Time'
```

---

## Example Workflow

```powershell
# 1. Start services
.\services\PRODUCTION_WIN.md  # Follow commands

# 2. Run quick test suite (skip long tests)
.\services\run_all_tests.ps1 -SkipSoak -SkipBreakpoint

# 3. View summary
notepad load_test_results_*/SUMMARY.md

# 4. Open baseline report
start load_test_results_*/baselinetest.html

# 5. Check for failures
Get-ChildItem load_test_results_*/*_failures.csv | ForEach-Object {
    $failures = Import-Csv $_.FullName
    if ($failures.Count -gt 0) {
        Write-Host "Failures in $($_.Name):" -ForegroundColor Red
        $failures | Format-Table
    }
}

# 6. If all looks good, run overnight Soak test
.\services\run_all_tests.ps1 -SkipBreakpoint  # Includes 1-hour Soak
```

---

## CI/CD Integration

### Run in Pipeline
```yaml
# Example GitHub Actions / Azure DevOps
- name: Run Load Tests
  run: |
    .\services\run_all_tests.ps1 -SkipSoak -SkipBreakpoint
  
- name: Upload Results
  uses: actions/upload-artifact@v3
  with:
    name: load-test-results
    path: load_test_results_*
```

### Automated Alerts
```powershell
# Check for failures and exit with error code
$failures = Get-ChildItem load_test_results_*/*_failures.csv
$totalFailures = 0
$failures | ForEach-Object {
    $count = (Import-Csv $_.FullName).Count
    $totalFailures += $count
}

if ($totalFailures -gt 100) {
    Write-Host "❌ Too many failures: $totalFailures" -ForegroundColor Red
    exit 1
}
```

---

## FAQ

**Q: How long does the full suite take?**  
A: ~2 hours with Soak test, ~45 minutes without

**Q: Can I run tests in parallel?**  
A: No, sequential execution prevents resource contention and gives accurate results

**Q: What if a test fails midway?**  
A: Script continues to next test, marks failed test in summary

**Q: Can I run against production?**  
A: **NO!** Only test staging/dev environments. Production load testing requires careful planning.

**Q: How often should I run tests?**  
A: Weekly for baseline, before each deployment, and after infrastructure changes

---

*For manual testing or individual test scenarios, see the main `locustfile.py` documentation.*
