## Run Individual Tests (Foreground - See Live Output)

```powershell
# Run tests from root directory
.\testing\test_smoke.ps1        # 2 min - Quick verification
.\testing\test_baseline.ps1     # 10 min - Performance baseline
.\testing\test_readheavy.ps1    # 15 min - 80% reads
.\testing\test_writeheavy.ps1   # 10 min - 80% writes
.\testing\test_spike.ps1        # 5 min - Traffic burst
.\testing\test_rampup.ps1       # 10 min - Gradual increase
.\testing\test_rampdown.ps1     # 10 min - Gradual decrease
.\testing\test_csv.ps1          # 10 min - All 200 users
.\testing\test_soak.ps1         # 1 hour - Memory leak detection
.\testing\test_breakpoint.ps1   # 20 min - Find limits
```

You will see live request stats. Press **Ctrl+C** to stop early.

---

## Test Scenarios

| Test | Users | Duration | Purpose |
|------|-------|----------|---------|
| Smoke | 10 | 2m | Verify all endpoints work |
| Baseline | 50 | 10m | Normal load baseline |
| Read-Heavy | 100 | 15m | Typical usage (80% reads) |
| Write-Heavy | 50 | 10m | Data entry (80% writes) |
| Spike | 200 | 5m | Sudden traffic burst |
| Ramp-Up | 100 | 10m | Gradual load increase |
| Ramp-Down | 100 | 10m | Graceful degradation |
| CSV | 200 | 10m | Full production load |
| Soak | 100 | 1h | Memory leak detection |
| Breakpoint | 500 | 20m | Find max capacity |

---

## Troubleshooting

**Check services running:**
```powershell
netstat -ano | findstr "8001 8002 8003 8004 8008 8009 8010 8011"
```

**Stop stuck tests:**
```powershell
Get-Process python* | Stop-Process -Force
```