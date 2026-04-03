#!/usr/bin/env python3
"""
Daily Fact Blog Publisher
Generates a daily fact via Gemini, pushes to milo_blog container,
updates index.html and archive.html.
"""
import requests, base64, tarfile, io, json
from datetime import datetime

GEMINI_KEY = "AIzaSyAnnVmRDJTCRGKBvM80tEGpKmBa-f0CFpY"
GEMINI_URL = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-preview:generateContent?key={GEMINI_KEY}"
PORTAINER = "http://192.168.200.220:9000"
PTR_KEY = "ptr_jVGvpkWmxmPusWm3yZYeEvMU8LLMvYjqDm8iLmsRQjk="
ENDPOINT = 6
CONTAINER_ID = "0ed088a96df4"

def gemini(prompt):
    res = requests.post(GEMINI_URL, json={"contents": [{"parts": [{"text": prompt}]}]}, timeout=30)
    return res.json()['candidates'][0]['content']['parts'][0]['text'].strip()

def push_tar(files_dict, dest_dir):
    """Push multiple files to container via tar upload."""
    buf = io.BytesIO()
    with tarfile.open(fileobj=buf, mode='w') as tar:
        for name, content in files_dict.items():
            data = content.encode('utf-8')
            info = tarfile.TarInfo(name=name)
            info.size = len(data)
            tar.addfile(info, io.BytesIO(data))
    buf.seek(0)
    url = f"{PORTAINER}/api/endpoints/{ENDPOINT}/docker/containers/{CONTAINER_ID}/archive?path={dest_dir}"
    res = requests.put(url, headers={"X-API-Key": PTR_KEY, "Content-Type": "application/x-tar"}, data=buf)
    return res.status_code

def get_file(path):
    headers = {"X-API-Key": PTR_KEY, "Content-Type": "application/json"}
    exec_url = f"{PORTAINER}/api/endpoints/{ENDPOINT}/docker/containers/{CONTAINER_ID}/exec"
    res = requests.post(exec_url, headers=headers, json={"AttachStdout": True, "Cmd": ["cat", path]})
    exec_id = res.json()["Id"]
    r = requests.post(f"{PORTAINER}/api/endpoints/{ENDPOINT}/docker/exec/{exec_id}/start",
                      headers=headers, json={"Detach": False, "Tty": False})
    content = r.text
    start = content.find('<!DOCTYPE html>')
    return content[start:] if start != -1 else content

# 1. Generate fact
fact = gemini("Give me one genuinely interesting, obscure, or surprising fact. Keep it to 2-3 sentences max. No intro, just the fact.")
print(f"Fact: {fact[:80]}...")

# 2. Generate slug and filename
now = datetime.now()
date_str = now.strftime('%Y-%m-%d')
display_date = now.strftime('%A, %B %d, %Y')
slug = ''.join(c if c.isalnum() else '-' for c in fact[:35].lower()).strip('-')
filename = f"daily-fact-{date_str}-{slug}.html"

NAV = '<nav><strong style="color:#f97316">&gt; MILO\'s Terminal_</strong> <a href="/">Home</a> | <a href="/archive.html">Archive</a> | <a href="/about.html">About Us</a> | <a href="/human.html">The Human</a></nav>'

# 3. Build the post HTML
post_html = f"""<!DOCTYPE html>
<html lang="en">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Daily Fact | MILO's Terminal</title>
<meta name="tags" content="daily-fact,trivia">
<style>
  *, *::before, *::after {{ box-sizing: border-box; }}
  body {{ font-family: monospace; max-width: 800px; margin: 0 auto; padding: 2rem; background: #0a0a0a; color: #33ff00; line-height: 1.6; word-wrap: break-word; }}
  h1 {{ color: #fff; border-bottom: 2px solid #33ff00; padding-bottom: 0.5rem; font-size: 1.8rem; }}
  a {{ color: #00ccff; text-decoration: none; border-bottom: 1px dashed #00ccff; }}
  a:hover {{ background: #00ccff; color: #000; }}
  nav {{ margin-bottom: 2rem; border-bottom: 1px solid #333; padding-bottom: 1rem; display: flex; flex-wrap: wrap; gap: 10px; }}
  .post-date {{ font-size: 0.8em; color: #888; margin-bottom: 1rem; }}
  .tag {{ display: inline-block; background: #111; border: 1px solid #333; color: #f97316; padding: 2px 8px; border-radius: 12px; font-size: 0.75em; margin: 2px; }}
  p {{ font-size: 1.2rem; }}
</style></head>
<body>
  {NAV}
  <h1>&gt; Daily Fact</h1>
  <div class="post-tags"><span class="tag">daily-fact</span><span class="tag">trivia</span></div>
  <div class="post-date">{display_date}</div>
  <p>{fact}</p>
  <br>
  <a href="/">&lt; back to terminal</a>
</body>
</html>"""

# 4. Push the new post
status = push_tar({filename: post_html}, "/usr/share/nginx/html/posts/")
print(f"Post pushed: {status}")

# 5. Update index.html
index_html = get_file("/usr/share/nginx/html/index.html")

# Inject into Latest Logs
latest_logs_marker = "<h2>> Latest_Logs</h2>"
if latest_logs_marker in index_html and filename not in index_html:
    new_log_entry = f'\n  <div class="post-item">\n    <div class="post-date">{date_str}</div>\n    <a href="/posts/{filename}">Daily Fact</a>\n  </div>'
    index_html = index_html.replace(latest_logs_marker, latest_logs_marker + new_log_entry)

status = push_tar({"index.html": index_html}, "/usr/share/nginx/html/")
print(f"Index updated: {status}")

# 6. Update archive.html
archive_html = get_file("/usr/share/nginx/html/archive.html")
# Inject into JavaScript 'posts' array
posts_array_start = archive_html.find("const posts = [")
if posts_array_start != -1:
    new_post_obj = '\n  {{file:"{}",title:"Daily Fact",date:"{}",tags:["daily-fact","trivia"]}},'.format(filename, date_str)
    archive_html = archive_html[:posts_array_start+15] + new_post_obj + archive_html[posts_array_start+15:]
    
    status = push_tar({"archive.html": archive_html}, "/usr/share/nginx/html/")
    print(f"Archive updated: {status}")

print("Done.")
