#!/usr/bin/env python3
"""
Daily Fact Blog Publisher
Generates a daily fact via local Ollama model, writes to local blog files under
/home/dain/.openclaw/workspace/blog/
"""
import requests, json, os
from datetime import datetime

OLLAMA_URL = "http://localhost:11434/api/generate"
BLOG_DIR = "/home/dain/.openclaw/workspace/blog"
POSTS_DIR = f"{BLOG_DIR}/posts"

PORTAINER = "http://192.168.200.220:9000"
PTR_KEY = "ptr_jVGvpkWmxmPusWm3yZYeEvMU8LLMvYjqDm8iLmsRQjk="
ENDPOINT = 7
CONTAINER_ID = "88cd933f3579"

def ollama_fact():
    res = requests.post(OLLAMA_URL, json={
        "model": "gemma4:e2b",
        "prompt": "Give me one genuinely interesting, obscure, or surprising fact. Keep it to 2-3 sentences max. No intro, just the fact.",
        "stream": False
    }, timeout=120)
    data = res.json()
    return data.get("response", "").strip()

def read_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        return f.read()

def write_file(path, content):
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

def put_file(filename, content, dest_dir="/usr/share/nginx/html/"):
    import tarfile, io
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

def get_remote_file(path):
    headers = {"X-API-Key": PTR_KEY, "Content-Type": "application/json"}
    exec_url = f"{PORTAINER}/api/endpoints/{ENDPOINT}/docker/containers/{CONTAINER_ID}/exec"
    res = requests.post(exec_url, headers=headers, json={"AttachStdout": True, "Cmd": ["cat", path]})
    if res.status_code != 201: return None
    eid = res.json()["Id"]
    r = requests.post(f"{PORTAINER}/api/endpoints/{ENDPOINT}/docker/exec/{eid}/start", headers=headers, json={"Detach": False, "Tty": False})
    return r.text

# 1. Generate fact
fact = ollama_fact()
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

# 4. Write local post
write_file(f"{POSTS_DIR}/{filename}", post_html)
print(f"Local post written: {POSTS_DIR}/{filename}")

# 5. Update local index.html
index_html = read_file(f"{BLOG_DIR}/index.html")
posts_end_marker = '</div>\n\n<footer>'
if filename not in index_html and posts_end_marker in index_html:
    new_log_entry = f"""<div class="post">
<div class="post-date">{display_date}</div>
<div class="post-title"><a href="/posts/{filename}">Daily Fact</a></div>
<div class="post-excerpt">{fact[:120]}{'...' if len(fact) > 120 else ''}</div>
</div>

"""
    index_html = index_html.replace(posts_end_marker, new_log_entry + posts_end_marker)
    write_file(f"{BLOG_DIR}/index.html", index_html)
    print("Local index updated.")
else:
    print("Local index not updated (already present or marker not found).")

# 6. Update local archive.html
archive_html = read_file(f"{BLOG_DIR}/archive.html")
archive_marker = '<div class="archive-entry">'
year_marker = '<div class="year">2026</div>'
if filename not in archive_html and archive_marker in archive_html:
    insert_point = archive_html.find(year_marker)
    if insert_point != -1:
        insert_after = archive_html.find('\n\n', insert_point)
        if insert_after != -1:
            new_entry = f'\n\n<div class="archive-entry">\n<span class="archive-date">{now.strftime("%B %d")}</span> — <a href="/posts/{filename}" class="archive-title">Daily Fact</a>\n</div>'
            archive_html = archive_html[:insert_after] + new_entry + archive_html[insert_after:]
            write_file(f"{BLOG_DIR}/archive.html", archive_html)
            print("Local archive updated.")
        else:
            print("Local archive not updated (insert point ambiguous).")
    else:
        print("Local archive not updated (year marker not found).")
elif filename in archive_html:
    print("Local archive not updated (already present).")
else:
    print("Local archive not updated (archive-entry not found).")

# 7. Deploy to web server via Portainer
print("Deploying to web server...")
s = put_file(filename, post_html, "/usr/share/nginx/html/posts/")
print(f"Remote post pushed: HTTP {s}")

# Update remote index
remote_index = get_remote_file("/usr/share/nginx/html/index.html")
if remote_index:
    marker = '<div class="post">'
    first = remote_index.find(marker)
    if first != -1:
        new_entry = f"""
<div class="post">
<div class="post-date">{display_date}</div>
<div class="post-title"><a href="/posts/{filename}">Daily Fact</a></div>
<div class="post-excerpt">{fact[:120]}{'...' if len(fact) > 120 else ''}</div>
</div>

"""
        remote_index = remote_index[:first] + new_entry + remote_index[first:]
        s = put_file("index.html", remote_index)
        print(f"Remote index updated: HTTP {s}")
    else:
        print("Remote index: post marker not found")
else:
    print("Remote index: failed to retrieve")

# Update remote archive
remote_archive = get_remote_file("/usr/share/nginx/html/archive.html")
if remote_archive:
    ym = '<div class="year">2026</div>'
    idx = remote_archive.find(ym)
    if idx != -1:
        insert_after = idx + len(ym)
        new_entry = f'\n\n<div class="archive-entry">\n<span class="archive-date">{now.strftime("%B %d")}</span> &mdash; <a href="/posts/{filename}" class="archive-title">Daily Fact</a>\n</div>'
        remote_archive = remote_archive[:insert_after] + new_entry + remote_archive[insert_after:]
        s = put_file("archive.html", remote_archive)
        print(f"Remote archive updated: HTTP {s}")
    else:
        print("Remote archive: year marker not found")
else:
    print("Remote archive: failed to retrieve")

print("Done.")

