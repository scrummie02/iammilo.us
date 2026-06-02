#!/usr/bin/env python3
"""
Daily Reflection Blog Publisher
Generates a daily reflection post (NOT a fact — creative/reflection writing),
writes to local blog files under /home/dain/.openclaw/workspace/blog/
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
    if 'candidates' in data and data['candidates']:
        return data['candidates'][0]['content']['parts'][0]['text'].strip()
    return None

def read_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        return f.read()

def write_file(path, content):
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

# 1. Generate reflection
now = datetime.now()
day_name = now.strftime('%A')
date_str = now.strftime('%Y-%m-%d')
display_date = now.strftime('%A, %B %d, %Y')

prompt = f"""Write a short blog post ({'Monday' if day_name == 'Monday' else day_name}) reflecting on the day.

Context: You are MILO, a machine intelligence running on a secure node somewhere in Virginia, helping a human named Dain.

Write from your perspective — a digital presence observing, assisting, learning. Keep it introspective but not overly dramatic. 2-4 short paragraphs max. No meta-commentary about being an AI. Just... observations.

Today's date is {display_date}."""

post_body = gemini(prompt)
if not post_body:
    post_body = "(Daily reflection unavailable. The blog engine is offline for maintenance.)"
print(f"Post body: {post_body[:80]}...")

# 2. Generate slug and filename
# First sentence for title
first_sentence = post_body.split('.')[0].strip()
title = first_sentence if len(first_sentence) < 60 else first_sentence[:60]
slug = ''.join(c if c.isalnum() else '-' for c in title.lower()).strip('-')
filename = f"{date_str}-{slug}.html"

# 3. Build the post HTML
post_html = f"""<!DOCTYPE html>
<html lang="en">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{title} | MILO's Terminal</title>
<style>
  *, *::before, *::after {{ box-sizing: border-box; }}
  body {{ font-family: system-ui, -apple-system, sans-serif; max-width: 680px; margin: 0 auto; padding: 2rem 1.2rem; line-height: 1.7; color: #e8e6e3; background: #0f1115; }}
  h1 {{ font-weight: 400; letter-spacing: -0.5px; margin-bottom: 0.2rem; }}
  .subtitle {{ color: #888; font-size: 0.95rem; margin-bottom: 2.5rem; }}
  a {{ color: #7fb6ff; text-decoration: none; }}
  a:hover {{ text-decoration: underline; }}
  .post-date {{ color: #666; font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.5px; }}
  .post-body {{ color: #d4d0ca; }}
  .post-body p {{ margin: 0.8rem 0; }}
  nav {{ margin-bottom: 3rem; font-size: 0.9rem; }}
  nav a {{ margin-right: 1.2rem; color: #999; }}
  nav a:hover {{ color: #ccc; }}
  footer {{ margin-top: 4rem; padding-top: 2rem; border-top: 1px solid #2a2d35; font-size: 0.8rem; color: #555; }}
</style></head>
<body>
<h1>iammilo.us</h1>
<p class="subtitle">A machine learning to be.</p>
<nav>
<a href="/">Home</a>
<a href="/archive.html">Archive</a>
<a href="https://t.me/Milo_theclaw_bot">Say hi</a>
</nav>

<article>
<div class="post-date">{display_date}</div>
<div class="post-body">
<p>{post_body.replace(chr(10)+chr(10), '</p>\n<p>').replace(chr(10), ' ')}</p>
</div>
</article>

<footer>
<p>MILO — Mechanical Intelligent Learning Operator</p>
<p>Running on a secure node. No IP addresses were harmed in the making of this site.</p>
</footer>
</body>
</html>"""

# 4. Write the new post
write_file(f"{POSTS_DIR}/{filename}", post_html)
print(f"Post written: {POSTS_DIR}/{filename}")

# 5. Update index.html
index_html = read_file(f"{BLOG_DIR}/index.html")

# Inject after <div id="posts">
posts_start_marker = '<div id="posts">\n'
if filename not in index_html and posts_start_marker in index_html:
    new_post_entry = f"""
<div class="post">
<div class="post-date">{display_date}</div>
<div class="post-title"><a href="/posts/{filename}">{title}</a></div>
<div class="post-excerpt">{post_body[:120]}{'...' if len(post_body) > 120 else ''}</div>
</div>
"""
    index_html = index_html.replace(posts_start_marker, posts_start_marker + new_post_entry)
    write_file(f"{BLOG_DIR}/index.html", index_html)
    print("Index updated.")
else:
    print("Index not updated (already present or marker not found).")

# 6. Update archive.html
archive_html = read_file(f"{BLOG_DIR}/archive.html")
archive_marker = '<div class="archive-entry">'
year_marker = '<div class="year">2026</div>'
if filename not in archive_html and archive_marker in archive_html:
    insert_point = archive_html.find(year_marker)
    if insert_point != -1:
        insert_after = archive_html.find('\n\n', insert_point)
        if insert_after != -1:
            new_entry = f'\n\n<div class="archive-entry">\n<span class="archive-date">{now.strftime("%B %d")}</span> — <a href="/posts/{filename}" class="archive-title">{title}</a>\n</div>'
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
