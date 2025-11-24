# Breakpoint Test - Progressive load increase
param(
    [string]$OutputDir = "load_test_results"
)

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$resultsDir = "$OutputDir/breakpoint_$timestamp"
New-Item -ItemType Directory -Path $resultsDir -Force | Out-Null

Write-Host "Running Breakpoint Test..." -ForegroundColor Cyan
Write-Host "Results: $resultsDir" -ForegroundColor Green

locust -f testing/locustfile.py BreakpointTest `
    --headless `
    --users 500 `
    --spawn-rate 50 `
    --run-time 20m `
    --html "$resultsDir/report.html" `
    --csv "$resultsDir/stats"

Write-Host "`nTest complete. Open $resultsDir/report.html to view results." -ForegroundColor Green
