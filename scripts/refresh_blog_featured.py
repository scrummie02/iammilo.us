#!/usr/bin/env python3
"""Update the featured blog post on iammilo.us homepage to show the latest non-daily-fact post."""
import requests, tarfile, io, re
from datetime import datetime

PORTAINER = "http://192.168.200.220:9000"
PTR_KEY = "ptr_jVGvpkWmxmPusWm3yZYeEvMU8LLMvYjqDm8iLmsRQjk="
ENDPOINT = 7
CONTAINER_ID = "0ed088a96df4"
headers = {"X-API-Key": PTR_KEY, "Content-Type": "application/json"}

exec_url = f"{PORTAINER}/api/endpoints/{ENDPOINT}/docker/containers/{CONTAINER_ID}/exec"

def get_file(path):
    res = requests.post(exec_url, headers=headers, json={"AttachStdout": True, "Cmd": ["cat", path]})
    if res.status_code != 201: return None
    eid = res.json()["Id"]
    r = requests.post(f"{PORTAINER}/api/endpoints/{ENDPOINT}/docker/exec/{eid}/start", headers=headers, json={"Detach": False, "Tty": False})
    return r.text

def put_file(filename, content, dest_dir="/usr/share/nginx/html/"):
    buf = io.BytesIO()
    with tarfile.open(fileobj=buf, mode='w') as tar:
        data = content.encode('utf-8')
        info = tarfile.TarInfo(name=filename)
        info.size = len(data)
        tar.addfile(info, io.BytesIO(data))
    buf.seek(0)
    url = f"{PORTAINER}/api/endpoints/{ENDPOINT}/docker/containers/{CONTAINER_ID}/archive?path={dest_dir}"
    res = requests.put(url, headers={"X-API-Key": PTR_KEY, "Content-Type": "application/x-tar"}, data=buf)
    return res.status_code

# --- 1. Find latest non-fact post from archive ---
archive = get_file("/usr/share/nginx/html/archive.html")
posts = []
for block in archive.split("{file:"):
    fm = re.match(r'"([^"]+)".*?title:"([^"]+)".*?date:"([^"]+)"', block)
    if fm:
        f, t, d = fm.group(1), fm.group(2), fm.group(3)
        if "daily-fact" not in f:
            posts.append({"file": f, "title": t, "date": d})
posts.sort(key=lambda p: p["date"], reverse=True)

if not posts:
    print("ERROR: No non-fact posts found")
    exit(1)

latest = posts[0]
print(f"Latest: {latest['title']} ({latest['date']})")

# --- 2. Get snippet from post ---
post_html = get_file(f"/usr/share/nginx/html/posts/{latest['file']}")
snippet = ""
if post_html:
    idx = post_html.find("</nav>")
    if idx > 0:
        pm = re.search(r'<p>(.*?)</p>', post_html[idx:])
        if pm:
            snippet = pm.group(1)
            if len(snippet) > 280:
                snippet = snippet[:277] + "..."
if not snippet:
    snippet = "A reflection on recent events."

# --- 3. Update featured section in index.html ---
index = get_file("/usr/share/nginx/html/index.html")

# Replace the three variable parts independently
# Date
date_pat = r'<div class="featured-date">[^<]+</div>'
index = re.sub(date_pat, f'<div class="featured-date">{latest["date"]}</div>', index)

# Title + link (h3)
h3_pat = r'<h3 style="margin-top:0;"><a href="/posts/[^"]+" style="color:#fff;">[^<]+</a></h3>'
new_h3 = f'<h3 style="margin-top:0;"><a href="/posts/{latest["file"]}" style="color:#fff;">{latest["title"]}</a></h3>'
index = re.sub(h3_pat, new_h3, index)

# Snippet paragraph (first <p> inside featured)
snip_pat = r'<div class="featured">[^<]*<div class="featured-date">[^<]*</div>\s*<h3[^<]*</h3>\s*<p>.*?</p>'
new_snip_block = f'<div class="featured">\n    <div class="featured-date">{latest["date"]}</div>\n    {new_h3}\n    <p>{snippet}</p>'
index = re.sub(snip_pat, new_snip_block, index, flags=re.DOTALL)

# Read link
link_pat = r'<a href="/posts/[^"]+">Read full log &rarr;</a>'
new_link = f'<a href="/posts/{latest["file"]}">Read full log &rarr;</a>'
index = re.sub(link_pat, new_link, index)

s = put_file("index.html", index)
print(f"Index updated: HTTP {s}")
