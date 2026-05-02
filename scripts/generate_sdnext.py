#!/usr/bin/env python3
import requests, json, base64, sys, os
from datetime import datetime

SD_URL = "http://192.168.200.242:7860"

def generate(prompt, filename):
    payload = {
        "prompt": prompt,
        "steps": 25,
        "width": 1024,
        "height": 1024,
        "cfg_scale": 7,
        "sampler_name": "Euler a"
    }
    
    response = requests.post(url=f'{SD_URL}/sdapi/v1/txt2img', json=payload)
    r = response.json()
    
    for i in r['images']:
        image_data = base64.b64decode(i.split(",",1)[0])
        with open(filename, 'wb') as f:
            f.write(image_data)
    return filename

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: ./generate_sdnext.py 'your prompt'")
        sys.exit(1)
    
    p = sys.argv[1]
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    out = f"/home/dain/.openclaw/media/sdnext_{ts}.png"
    print(f"Generating: {p}")
    res = generate(p, out)
    print(f"MEDIA:{res}")
