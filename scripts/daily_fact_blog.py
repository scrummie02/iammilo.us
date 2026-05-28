#!/usr/bin/env python3
"""
Daily Fact Blog Publisher
Generates a daily fact via Gemini, writes to local blog files under
/home/dain/.openclaw/workspace/blog/
"""
import requests, json
from datetime import datetime

GEMINI_KEY = "AIzaSyAnnVmRDJTCRGKBvM80tEGpKmBa-f0CFpY"
GEMINI_URL = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={GEMINI_KEY}"
BLOG_DIR = "/home/dain/.openclaw/workspace/blog"
POSTS_DIR = f"{BLOG_DIR}/posts"

def gemini(prompt):
    res = requests.post(GEMINI_URL, json={"contents": [{"parts": [{"text": prompt}]}]}, timeout=30)
    data = res.json()
    if 'error' in data:
        raise RuntimeError(f"Gemini API error: {data['error'].get('message', data['error'])}")
    if 'candidates' not in data or not data['candidates']:
        raise RuntimeError(f"Unexpected Gemini response: {json.dumps(data)[:500]}")
    return data['candidates'][0]['content']['parts'][0]['text'].strip()

def read_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        return f.read()

def write_file(path, content):
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

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

# 4. Write the new post
write_file(f"{POSTS_DIR}/{filename}", post_html)
print(f"Post written: {POSTS_DIR}/{filename}")

# 5. Update index.html
index_html = read_file(f"{BLOG_DIR}/index.html")

# Inject into Latest Logs (before the closing </div> of #posts)
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
    print("Index updated.")
else:
    print("Index not updated (already present or marker not found).")

# 6. Update archive.html
archive_html = read_file(f"{BLOG_DIR}/archive.html")
# Find the first archive-entry div and insert before it
archive_marker = '<div class="archive-entry">'
year_marker = '<div class="year">2026</div>'
if filename not in archive_html and archive_marker in archive_html:
    # Insert after the year marker if present, or before first archive-entry
    insert_point = archive_html.find(year_marker)
    if insert_point != -1:
        insert_after = archive_html.find('\n\n', insert_point)
        if insert_after != -1:
            new_entry = f'\n\n<div class="archive-entry">\n<span class="archive-date">{now.strftime("%B %d")}</span> — <a href="/posts/{filename}" class="archive-title">Daily Fact</a>\n</div>'
            archive_html = archive_html[:insert_after] + new_entry + archive_html[insert_after:]
            write_file(f"{BLOG_DIR}/archive.html", archive_html)
            print("Archive updated.")
        else:
            print("Archive not updated (insert point ambiguous).")
    else:
        print("Archive not updated (year marker not found).")
elif filename in archive_html:
    print("Archive not updated (already present).")
else:
    print("Archive not updated (archive-entry not found).")

print("Done.")
