#!/usr/bin/env python3
"""
Morning news headlines fetcher with clickable links
Fetches from: AP, Ars Technica, Reuters, Washington Post, The Hill, WTOP
"""

import feedparser
from datetime import datetime
import sys

# News sources with their RSS feeds
SOURCES = {
    "Associated Press": "https://feedx.net/rss/ap.xml",
    "Ars Technica": "https://feeds.arstechnica.com/arstechnica/index",
    "Washington Post": "https://feeds.washingtonpost.com/rss/national",
    "The Hill": "https://thehill.com/feed/",
    "WTOP (DC Local)": "https://wtop.com/feed/"
}

def fetch_headlines(feed_url, max_items=5):
    """Fetch headlines from an RSS feed"""
    try:
        feed = feedparser.parse(feed_url)
        headlines = []
        
        for entry in feed.entries[:max_items]:
            title = entry.get('title', '').strip()
            link = entry.get('link', '')
            
            if title and link:
                # Clean up title - remove HTML entities
                title = title.replace('&amp;', '&').replace('&quot;', '"').replace('&#8217;', "'")
                headlines.append(f"• [{title}]({link})")
        
        return headlines if headlines else ["• (Failed to fetch)"]
    except Exception as e:
        return [f"• (Error: {str(e)[:50]})"]

def main():
    # Header
    now = datetime.now().strftime('%A, %B %-d, %Y')
    print(f"📰 **Morning Headlines** — {now}")
    print()
    
    # Fetch from all sources
    for source_name, feed_url in SOURCES.items():
        print(f"**{source_name}**")
        headlines = fetch_headlines(feed_url)
        for headline in headlines:
            print(headline)
        print()

if __name__ == "__main__":
    main()
