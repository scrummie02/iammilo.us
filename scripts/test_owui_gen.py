import requests
import time

URL = "http://192.168.200.242:4040/api/v1/images/generations"
TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjI3ODAyNGRiLWU5MDYtNDNhZS1hZTU5LTdmOTM1ZTY1OWEzNiIsImV4cCI6MTc3NzkxMDk2MCwianRpIjoiMTA0N2JmZWEtM2E5NS00NDNjLTljMjYtZDAzM2ViMjZjYzg1In0.qWFM_Fi8yLgsJKRrs613bXQmpM96nGDSN368slXIsg4"

headers = {
    "Authorization": f"Bearer {TOKEN}",
    "Content-Type": "application/json"
}

payload = {
    "prompt": "a simple green cube",
    "n": 1,
    "size": "512x512"
}

print(f"Sending request to {URL}...")
try:
    r = requests.post(URL, headers=headers, json=payload, timeout=60)
    print(f"Status: {r.status_code}")
    print(r.text[:500])
except Exception as e:
    print(f"Error: {e}")