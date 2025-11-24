# Smoke Test - Quick verification of all endpoints
param(
    [string]$OutputDir = "load_test_results"
)

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$resultsDir = "$OutputDir/smoke_$timestamp"
New-Item -ItemType Directory -Path $resultsDir -Force | Out-Null

Write-Host "Running Smoke Test..." -ForegroundColor Cyan
Write-Host "Results: $resultsDir" -ForegroundColor Green

locust -f testing/locustfile.py SmokeTest `
    --headless `
    --users 10 `
    --spawn-rate 2 `
    --run-time 2m `
    --html "$resultsDir/report.html" `
    --csv "$resultsDir/stats"

Write-Host "`nTest complete. Open $resultsDir/report.html to view results." -ForegroundColor Green
