## Run Individual Tests (Foreground - See Live Output)

```powershell
# Run tests from root directory (Total: ~40 min for all)
.\testing\test_smoke.ps1        # 1 min - Quick verification
.\testing\test_baseline.ps1     # 3 min - Performance baseline
.\testing\test_readheavy.ps1    # 5 min - 80% reads
.\testing\test_writeheavy.ps1   # 5 min - 80% writes
.\testing\test_spike.ps1        # 3 min - Traffic burst
.\testing\test_rampup.ps1       # 5 min - Gradual increase
.\testing\test_rampdown.ps1     # 5 min - Gradual decrease
.\testing\test_csv.ps1          # 5 min - All users
.\testing\test_soak.ps1         # 15 min - Stability
.\testing\test_breakpoint.ps1   # 10 min - Find limits
```

You will see live request stats. Press **Ctrl+C** to stop early.

---

## Test Scenarios

| Test | Users | Duration | Purpose |
|------|-------|----------|---------||
| Smoke | 5 | 1m | Verify all endpoints work |
| Baseline | 30 | 3m | Normal load baseline |
| Read-Heavy | 50 | 5m | Typical usage (80% reads) |
| Write-Heavy | 30 | 5m | Data entry (80% writes) |
| Spike | 100 | 3m | Sudden traffic burst |
| Ramp-Up | 50 | 5m | Gradual load increase |
| Ramp-Down | 50 | 5m | Graceful degradation |
| CSV | 100 | 5m | Production simulation |
| Soak | 50 | 15m | Stability testing |
| Breakpoint | 200 | 10m | Find max capacity |

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