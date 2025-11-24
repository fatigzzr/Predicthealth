# Soak Test - Extended duration (1 hour)
param(
    [string]$OutputDir = "load_test_results"
)

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$resultsDir = "$OutputDir/soak_$timestamp"
New-Item -ItemType Directory -Path $resultsDir -Force | Out-Null

Write-Host "Running Soak Test (15 min)..." -ForegroundColor Cyan
Write-Host "Results: $resultsDir" -ForegroundColor Green

locust -f testing/locustfile.py SoakTest `
    --headless `
    --users 50 `
    --spawn-rate 10 `
    --run-time 15m `
    --html "$resultsDir/report.html" `
    --csv "$resultsDir/stats"

Write-Host "`nTest complete. Open $resultsDir/report.html to view results." -ForegroundColor Green
