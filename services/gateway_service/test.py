import requests

url = "http://127.0.0.1:8001/openapi.json"
resp = requests.get(url)
print(resp.status_code)
print(resp.text[:500])  # first 500 chars
