# locustfile.py
# Locust test suite: baseline, smoke, read-heavy, write-heavy, ramp, spike, soak, break-point
# Usage example:
#   TEST_TYPE=baseline locust -f locustfile.py --host=http://localhost:5001
#   TEST_TYPE=spike locust -f locustfile.py --host=http://localhost:5001

import os
import csv
import itertools
import threading
import time
from locust import HttpUser, task, between, LoadTestShape, events, TaskSet, constant

# ---------- CSV FEEDER ----------
CSV_PATH = os.getenv("USERS_CSV", "usuarios.csv")  # file with columns: id_rol,email,contraseña

def load_credentials(path):
    creds = []
    with open(path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for r in reader:
            # permissive: expect email and contraseña columns
            creds.append({"username": r.get("email") or r.get("username"), "password": r.get("contraseña") or r.get("password")})
    if not creds:
        raise RuntimeError(f"No credentials found in {path}")
    return creds

_CREDENTIALS = load_credentials(CSV_PATH)
_CRED_LOCK = threading.Lock()
_CRED_ITER = itertools.cycle(_CREDENTIALS)

def get_next_cred():
    with _CRED_LOCK:
        return next(_CRED_ITER)

# ---------- USER BEHAVIOR ----------
API_PREFIX = os.getenv("API_PREFIX", "/api")
LOGIN_PATH = f"{API_PREFIX}/login"
ME_PATH = f"{API_PREFIX}/me"
# Optional write endpoint to simulate authenticated write traffic (if your app exposes one).
WRITE_PATH = os.getenv("WRITE_PATH", f"{API_PREFIX}/items")  # adjust in env if needed

class AppBehavior(TaskSet):
    token_lock = threading.Lock()

    def on_start(self):
        cred = get_next_cred()
        try:
            res = self.client.post(LOGIN_PATH, json={"username": cred["username"], "password": cred["password"]}, name="login")
            if res.status_code == 200:
                data = res.json()
                token = data.get("access_token") or data.get("token") or data.get("jwt")
                if not token:
                    # try common name
                    token = data.get("token")
                self.token = token
                self.auth_headers = {"Authorization": f"Bearer {self.token}"} if self.token else {}
            else:
                self.token = None
                self.auth_headers = {}
        except Exception:
            self.token = None
            self.auth_headers = {}

    @task(8)
    def me(self):
        self.client.get(ME_PATH, headers=self.auth_headers, name="me")

    @task(2)
    def write_op(self):
        # simple write simulation; body can be adjusted to match real API
        payload = {"title": "load-test", "timestamp": int(time.time())}
        self.client.post(WRITE_PATH, json=payload, headers=self.auth_headers, name="write_op")

class WebsiteUser(HttpUser):
    tasks = [AppBehavior]
    wait_time = between(1, 3)  # small think time; adjust as needed

# ---------- LOAD SHAPE ----------
class MultiScenarioShape(LoadTestShape):
    """
    Single shape class that reads TEST_TYPE env var and produces:
      - baseline: constant users
      - smoke: small short test
      - read-heavy: ramp to a target then hold (read-heavy simulated by task weights)
      - writeheavy: ramp to target with higher write ratio (adjust WRITE_TASK_WEIGHT env var)
      - ramp: linear ramp up then down
      - spike: sudden high users for brief period
      - soak: long steady load
      - break-point: increasing steps to find failure
    """

    def __init__(self):
        super().__init__()
        self.test_type = os.getenv("TEST_TYPE", "baseline").lower()
        # Common defaults (can be overridden with env vars)
        self.baseline_users = int(os.getenv("BASELINE_USERS", "50"))
        self.smoke_users = int(os.getenv("SMOKE_USERS", "5"))
        self.read_users = int(os.getenv("READ_USERS", "200"))
        self.write_users = int(os.getenv("WRITE_USERS", "150"))
        self.ramp_users = int(os.getenv("RAMP_MAX_USERS", "300"))
        self.spike_users = int(os.getenv("SPIKE_USERS", "500"))
        self.soak_users = int(os.getenv("SOAK_USERS", "100"))
        self.breakpoint_step = int(os.getenv("BP_STEP", "50"))
        self.bp_max = int(os.getenv("BP_MAX", "600"))
        self.step_duration = int(os.getenv("STEP_DURATION", "60"))  # seconds per step
        self.ramp_duration = int(os.getenv("RAMP_DURATION", "300"))  # seconds for full ramp
        self.spike_duration = int(os.getenv("SPIKE_DURATION", "60"))
        self.soak_duration = int(os.getenv("SOAK_DURATION", "3600"))  # 1 hour by default

        # read/write task weighting can be controlled by environment and is implemented in TaskSet weights above
        # but you can tune WRITE_PATH and task weights via env vars if needed.

    def tick(self):
        run_time = self.get_run_time()
        t = run_time

        tt = self.test_type
        if tt == "baseline":
            return (self.baseline_users, 1)
        if tt == "smoke":
            # small number of users for a short time
            if t < 60:
                return (self.smoke_users, 1)
            return None
        if tt == "read-heavy":
            # ramp up to read_users in ramp_duration, then hold for ramp_duration
            if t < self.ramp_duration:
                users = int(self.read_users * (t / max(1, self.ramp_duration)))
                return (max(1, users), 1)
            if t < 2 * self.ramp_duration:
                return (self.read_users, 1)
            return None
        if tt == "writeheavy":
            if t < self.ramp_duration:
                users = int(self.write_users * (t / max(1, self.ramp_duration)))
                return (max(1, users), 1)
            if t < 2 * self.ramp_duration:
                return (self.write_users, 1)
            return None
        if tt == "ramp":
            # linear ramp up then down symmetric
            half = self.ramp_duration
            if t < half:
                users = int(self.ramp_users * (t / max(1, half)))
                return (max(1, users), 1)
            if t < 2 * half:
                users = int(self.ramp_users * (1 - ((t - half) / max(1, half))))
                return (max(1, users), 1)
            return None
        if tt == "spike":
            if t < 30:
                return (int(self.spike_users * 0.2), 1)
            if t < 30 + self.spike_duration:
                return (self.spike_users, 1)
            # cool down
            if t < 30 + self.spike_duration + 60:
                return (int(self.spike_users * 0.1), 1)
            return None
        if tt == "soak":
            # ramp to soak_users quickly, hold for soak_duration
            ramp = 120
            if t < ramp:
                users = int(self.soak_users * (t / ramp))
                return (max(1, users), 1)
            if t < ramp + self.soak_duration:
                return (self.soak_users, 1)
            return None
        if tt == "break-point" or tt == "breakpoint":
            # step-wise increase until bp_max
            step = self.step_duration
            current_step = int(t // step)
            users = min(self.bp_max, (current_step + 1) * self.breakpoint_step)
            if users <= 0 or t > (int(self.bp_max / max(1, self.breakpoint_step)) + 2) * step:
                return None
            return (users, 1)
        # default fallback
        return (self.baseline_users, 1)

# ---------- EVENTS (optional hooks to report) ----------
@events.test_start.add_listener
def on_test_start(environment, **kwargs):
    # rotate CSV iterator to different starting point per test to reduce same-credential collisions
    # advance iterator by a random offset
    import random
    offset = random.randint(0, len(_CREDENTIALS) - 1)
    with _CRED_LOCK:
        for _ in range(offset):
            next(_CRED_ITER)

# End of locustfile.py
