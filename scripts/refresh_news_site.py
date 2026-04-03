#!/usr/bin/env python3
"""Refresh news.dainbentley.com every 4 hours from RSS feeds."""
import urllib.request, xml.etree.ElementTree as ET, html, base64, requests
from datetime import datetime

PORTAINER = "http://192.168.200.220:9000"
PTR_KEY = "ptr_jVGvpkWmxmPusWm3yZYeEvMU8LLMvYjqDm8iLmsRQjk="
ENDPOINT = 6
CONTAINER = "milo_news"

feeds = {
    "WORLD NEWS":     ("https://moxie.foxnews.com/google-publisher/world.xml", 5),
    "TOP HEADLINES":  ("http://rss.cnn.com/rss/cnn_topstories.rss", 5),
    "NPR":            ("https://feeds.npr.org/1001/rss.xml", 5),
    "REUTERS":        ("https://news.yahoo.com/rss/world", 5),
    "SCIENCE":        ("https://feeds.bbci.co.uk/news/science_and_environment/rss.xml", 5),
    "TECHNOLOGY":     ("https://feeds.arstechnica.com/arstechnica/index", 5),
}

cols = [
    ["WORLD NEWS", "TOP HEADLINES", "NPR"],
    ["REUTERS", "SCIENCE"],
    ["TECHNOLOGY"],
]

def get_items(url, n):
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req, timeout=10) as r:
            tree = ET.fromstring(r.read())
        items = []
        for item in tree.iter("item"):
            title = item.findtext("title", "").strip()
            link = item.findtext("link", "#").strip()
            if title and link:
                items.append((html.escape(title), link))
            if len(items) >= n:
                break
        return items
    except:
        return []

now = datetime.now()
today = now.strftime("%A, %B %d, %Y").upper()
updated = now.strftime("%I:%M %p ET")

page = f'''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>DAIN REPORT</title>
<style>
  body {{ background-color: #fcfcfc; color: #000; font-family: "Times New Roman", Times, serif; text-align: center; margin: 0; padding: 20px; }}
  .header {{ border-bottom: 2px solid #000; padding-bottom: 10px; margin-bottom: 20px; border-top: 1px solid #000; padding-top: 5px; }}
  h1 {{ font-family: "Arial Black", Gadget, sans-serif; font-size: 5rem; margin: 0; text-transform: uppercase; font-style: italic; letter-spacing: -4px; line-height: 1; }}
  .date {{ font-weight: bold; font-size: 1.2rem; margin-top: 5px; text-transform: uppercase; }}
  .container {{ display: flex; flex-wrap: wrap; justify-content: center; gap: 40px; text-align: left; max-width: 1200px; margin: 0 auto; }}
  .column {{ flex: 1; min-width: 300px; border-right: 1px solid #ddd; padding-right: 20px; }}
  .column:last-child {{ border-right: none; }}
  .section-title {{ color: #cc0000; font-family: Arial, sans-serif; font-weight: bold; font-size: 0.9rem; border-bottom: 1px solid #000; margin-top: 25px; margin-bottom: 15px; padding-bottom: 2px; }}
  a {{ display: block; color: #0000ee; text-decoration: none; font-size: 1.4rem; font-weight: bold; line-height: 1.1; margin-bottom: 20px; }}
  a:hover {{ text-decoration: underline; background: #ffff00; }}
  .updated {{ color: #888; font-size: 0.8rem; margin-top: 30px; }}
</style>
</head>
<body>
  <div class="header">
    <h1>DAIN REPORT</h1>
    <div class="date">{today} &mdash; UPDATED {updated}</div>
  </div>
  <div class="container">
'''

for col_sections in cols:
    page += '<div class="column">'
    for section in col_sections:
        url, n = feeds[section]
        items = get_items(url, n)
        if items:
            page += f'<div class="section-title">{section}</div>'
            for title, link in items:
                page += f'<a href="{link}" target="_blank">{title}</a>'
    page += '</div>'

page += f'</div></body></html>'

# Push to container
hdr = {"X-API-Key": PTR_KEY, "Content-Type": "application/json"}
exec_res = requests.post(
    f"{PORTAINER}/api/endpoints/{ENDPOINT}/docker/containers/{CONTAINER}/exec",
    headers=hdr,
    json={"AttachStdout": True, "AttachStderr": True,
          "Cmd": ["sh", "-c", f"echo {base64.b64encode(page.encode()).decode()} | base64 -d > /usr/share/nginx/html/index.html"]}
)
exec_id = exec_res.json().get("Id")
requests.post(f"{PORTAINER}/api/endpoints/{ENDPOINT}/docker/exec/{exec_id}/start",
              headers=hdr, json={"Detach": False, "Tty": False})
print(f"Updated at {datetime.now().strftime('%H:%M')}")
