# PredictHealth - Automated Load Testing Suite
# Runs all 10 Locust test scenarios and generates comprehensive reports

param(
    [string]$TargetHost = "http://localhost",
    [switch]$SkipSoak,
    [switch]$SkipBreakpoint
)

$ErrorActionPreference = "Stop"

# Configuration
$LOCUST_FILE = "services/locustfile.py"
$TIMESTAMP = Get-Date -Format "yyyyMMdd_HHmmss"
$RESULTS_DIR = "load_test_results_$TIMESTAMP"

# Create results directory
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "PredictHealth Load Testing Suite" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Results will be saved to: $RESULTS_DIR" -ForegroundColor Green
New-Item -ItemType Directory -Path $RESULTS_DIR -Force | Out-Null

# Test suite configuration
$tests = @(
    @{
        Name = "1. Smoke Test"
        Class = "SmokeTest"
        Users = 10
        SpawnRate = 2
        Runtime = "2m"
        Description = "Quick verification of all endpoints"
    },
    @{
        Name = "2. Baseline Test"
        Class = "BaselineTest"
        Users = 50
        SpawnRate = 5
        Runtime = "10m"
        Description = "Establish performance baseline"
    },
    @{
        Name = "3. Read-Heavy Test"
        Class = "ReadHeavyTest"
        Users = 100
        SpawnRate = 10
        Runtime = "15m"
        Description = "Simulate typical CMS usage (80% reads)"
    },
    @{
        Name = "4. Write-Heavy Test"
        Class = "WriteHeavyTest"
        Users = 50
        SpawnRate = 5
        Runtime = "10m"
        Description = "Test database write capacity (80% writes)"
    },
    @{
        Name = "5. Spike Test"
        Class = "SpikeTest"
        Users = $null  # Controlled by custom shape
        SpawnRate = $null
        Runtime = $null
        Description = "Sudden traffic burst (50→200→50 users)"
    },
    @{
        Name = "6. Ramp-Up Test"
        Class = "RampUpTest"
        Users = $null  # Controlled by custom shape
        SpawnRate = $null
        Runtime = $null
        Description = "Gradual load increase (10→100 users)"
    },
    @{
        Name = "7. Ramp-Down Test"
        Class = "RampDownTest"
        Users = $null  # Controlled by custom shape
        SpawnRate = $null
        Runtime = $null
        Description = "Gradual load decrease (100→10 users)"
    },
    @{
        Name = "8. CSV Test"
        Class = "CSVTest"
        Users = 200
        SpawnRate = 20
        Runtime = "10m"
        Description = "Production simulation (all 200 DB users)"
    },
    @{
        Name = "9. Soak Test"
        Class = "SoakTest"
        Users = 100
        SpawnRate = 10
        Runtime = "1h"
        Description = "Extended duration (memory leak detection)"
        Skip = $SkipSoak
    },
    @{
        Name = "10. Breakpoint Test"
        Class = "BreakpointTest"
        Users = $null  # Progressive increase
        SpawnRate = $null
        Runtime = $null
        Description = "Find system capacity limits"
        Skip = $SkipBreakpoint
    }
)

# Function to run a single test
function Run-LoadTest {
    param($TestConfig)
    
    if ($TestConfig.Skip) {
        Write-Host "SKIPPED: $($TestConfig.Name)" -ForegroundColor Yellow
        Write-Host "   $($TestConfig.Description)" -ForegroundColor DarkGray
        Write-Host ""
        return
    }
    
    Write-Host "RUNNING: $($TestConfig.Name)" -ForegroundColor Green
    Write-Host "   $($TestConfig.Description)" -ForegroundColor Gray
    
    $outputPrefix = "$RESULTS_DIR/$($TestConfig.Class.ToLower())"
    
    # Build locust command
    $locustCmd = "locust -f $LOCUST_FILE $($TestConfig.Class) --headless --host $TargetHost --html $outputPrefix.html --csv $outputPrefix"
    
    # Add users/spawn-rate/runtime if specified (not for custom shapes)
    if ($null -ne $TestConfig.Users) {
        $locustCmd += " --users $($TestConfig.Users) --spawn-rate $($TestConfig.SpawnRate)"
    }
    if ($null -ne $TestConfig.Runtime) {
        $locustCmd += " --run-time $($TestConfig.Runtime)"
    }
    
    Write-Host "   Command: $locustCmd" -ForegroundColor DarkGray
    
    # Run test and capture output
    $startTime = Get-Date
    try {
        Invoke-Expression $locustCmd 2>&1 | Tee-Object -FilePath "$outputPrefix.log"
        $exitCode = $LASTEXITCODE
    } catch {
        Write-Host "   ERROR: Test failed with exception" -ForegroundColor Red
        Write-Host "   $_" -ForegroundColor Red
        $exitCode = 1
    }
    $endTime = Get-Date
    $duration = $endTime - $startTime
    
    if ($exitCode -eq 0) {
        Write-Host "   COMPLETED in $($duration.ToString('mm\:ss'))" -ForegroundColor Green
    } else {
        Write-Host "   FAILED (exit code: $exitCode)" -ForegroundColor Red
    }
    
    Write-Host ""
}

# Pre-flight checks
Write-Host "Checking prerequisites..." -ForegroundColor Yellow
Write-Host ""

# Check if locust is installed
try {
    $locustVersion = locust --version 2>&1 | Select-String "locust" | Select-Object -First 1
    Write-Host "Locust found: $locustVersion" -ForegroundColor Green
} catch {
    Write-Host "Locust not found. Install with: pip install locust==2.31.8" -ForegroundColor Red
    exit 1
}

# Check if services are running
Write-Host ""
Write-Host "Checking if microservices are running..." -ForegroundColor Yellow
$ports = @(8001, 8002, 8003, 8004, 8008, 8009, 8010, 8011)
$runningServices = 0

foreach ($port in $ports) {
    $connection = Test-NetConnection -ComputerName localhost -Port $port -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
    if ($connection.TcpTestSucceeded) {
        $runningServices++
        Write-Host "  Port $port is open" -ForegroundColor Green
    } else {
        Write-Host "  Port $port is NOT open" -ForegroundColor Red
    }
}

if ($runningServices -lt 8) {
    Write-Host ""
    Write-Host "WARNING: Only $runningServices/8 services are running!" -ForegroundColor Yellow
    Write-Host "   Start all services before testing (see PRODUCTION_WIN.md)" -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "Continue anyway? (y/N)"
    if ($continue -ne "y" -and $continue -ne "Y") {
        Write-Host "Aborted." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "All 8 services are running" -ForegroundColor Green
}

# Check if users.csv exists
if (Test-Path "services/users.csv") {
    $userCount = (Get-Content "services/users.csv" | Measure-Object -Line).Lines - 1
    Write-Host "users.csv found ($userCount users)" -ForegroundColor Green
} else {
    Write-Host "users.csv not found (CSV test will use hardcoded users)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Starting Test Suite" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($SkipSoak) {
    Write-Host "Soak test will be skipped (use without -SkipSoak to include)" -ForegroundColor Yellow
}
if ($SkipBreakpoint) {
    Write-Host "Breakpoint test will be skipped (use without -SkipBreakpoint to include)" -ForegroundColor Yellow
}

Write-Host ""
Start-Sleep -Seconds 2

# Run all tests
$totalTests = $tests.Count
$currentTest = 0
$failedTests = @()

foreach ($test in $tests) {
    $currentTest++
    Write-Host "[$currentTest/$totalTests] " -NoNewline -ForegroundColor Cyan
    
    try {
        Run-LoadTest -TestConfig $test
    } catch {
        Write-Host "   EXCEPTION: $_" -ForegroundColor Red
        $failedTests += $test.Name
    }
    
    # Small delay between tests
    if ($currentTest -lt $totalTests) {
        Write-Host "   Waiting 10 seconds before next test..." -ForegroundColor DarkGray
        Start-Sleep -Seconds 10
    }
}

# Generate summary report
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Suite Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$summaryFile = "$RESULTS_DIR/SUMMARY.md"
$summaryContent = @"
# PredictHealth Load Testing Summary
**Date:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")  
**Host:** $TargetHost  
**Total Tests:** $totalTests  
**Failed Tests:** $($failedTests.Count)

## Test Results

"@

foreach ($test in $tests) {
    if ($test.Skip) {
        $summaryContent += "- **$($test.Name)** - SKIPPED`n"
    } else {
        $htmlFile = "$RESULTS_DIR/$($test.Class.ToLower()).html"
        if (Test-Path $htmlFile) {
            $summaryContent += "- **$($test.Name)** - [View Report](./$($test.Class.ToLower()).html)`n"
        } else {
            $summaryContent += "- **$($test.Name)** - FAILED`n"
        }
    }
}

$summaryContent += @"

## Files Generated

"@

Get-ChildItem $RESULTS_DIR -File | ForEach-Object {
    $summaryContent += "- ``$($_.Name)``"
    if ($_.Extension -eq ".html") {
        $summaryContent += " - HTML Report"
    } elseif ($_.Extension -eq ".csv") {
        $summaryContent += " - CSV Data"
    } elseif ($_.Extension -eq ".log") {
        $summaryContent += " - Test Log"
    }
    $summaryContent += "`n"
}

$summaryContent += @"

## Quick Analysis

Open HTML reports in browser to view:
- Response time distribution (p50, p95, p99)
- Requests per second over time
- Failure rates by endpoint
- Detailed error logs

## Recommendations

1. **Check Baseline Report** - Establish your performance benchmarks
2. **Review Failures** - Any endpoint with >1% failure rate needs investigation
3. **Compare Results** - Run periodically and compare response times
4. **Soak Test** - Run overnight to detect memory leaks
5. **Breakpoint Test** - Find your system's capacity limits

---
*Generated by PredictHealth Load Testing Suite*
"@

Set-Content -Path $summaryFile -Value $summaryContent

Write-Host "Results saved to: $RESULTS_DIR" -ForegroundColor Green
Write-Host ""
Write-Host "Generated files:" -ForegroundColor Yellow
Get-ChildItem $RESULTS_DIR -File | ForEach-Object {
    Write-Host "  - $($_.Name)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Summary report: $summaryFile" -ForegroundColor Cyan
Write-Host ""
Write-Host "View results:" -ForegroundColor Yellow
Write-Host "  notepad $summaryFile" -ForegroundColor White
Write-Host "  start $RESULTS_DIR\baselinetest.html" -ForegroundColor White
Write-Host ""

if ($failedTests.Count -gt 0) {
    Write-Host "WARNING: $($failedTests.Count) test(s) failed:" -ForegroundColor Red
    $failedTests | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 1
} else {
    Write-Host "All tests completed successfully!" -ForegroundColor Green
    exit 0
}
