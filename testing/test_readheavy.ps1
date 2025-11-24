# Read-Heavy Test - 80% reads, 20% writes
param(
    [string]$OutputDir = "load_test_results"
)

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$resultsDir = "$OutputDir/readheavy_$timestamp"
New-Item -ItemType Directory -Path $resultsDir -Force | Out-Null

Write-Host "Running Read-Heavy Test..." -ForegroundColor Cyan
Write-Host "Results: $resultsDir" -ForegroundColor Green

locust -f testing/locustfile.py ReadHeavyTest `
    --headless `
    --users 100 `
    --spawn-rate 10 `
    --run-time 15m `
    --html "$resultsDir/report.html" `
    --csv "$resultsDir/stats"

Write-Host "`nTest complete. Open $resultsDir/report.html to view results." -ForegroundColor Green
