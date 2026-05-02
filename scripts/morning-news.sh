#!/bin/bash
# Morning news headlines for Discord #news channel with clickable links
# Fetches from: AP, Ars Technica, Reuters, Washington Post, The Hill, WTOP

TEMP_FILE="/tmp/morning-headlines.txt"
> "$TEMP_FILE"

echo "📰 **Morning Headlines** — $(date '+%A, %B %-d, %Y')" >> "$TEMP_FILE"
echo "" >> "$TEMP_FILE"

# Function to clean up HTML entities
clean_html() {
  sed 's/&amp;/\&/g; s/&lt;/</g; s/&gt;/>/g; s/&#8217;/'"'"'/g; s/&#8220;/"/g; s/&#8221;/"/g; s/&quot;/"/g; s/&#039;/'"'"'/g'
}

# Function to parse RSS feed with xmllint (more reliable)
parse_rss() {
  local url="$1"
  local count="${2:-5}"
  
  curl -s "$url" 2>/dev/null | \
    xmllint --xpath "//item" - 2>/dev/null | \
    sed 's/<item>/\n<item>/g' | \
    grep '<item>' | \
    head -n "$count" | \
    while IFS= read -r item; do
      title=$(echo "$item" | sed -n 's/.*<title>\(.*\)<\/title>.*/\1/p' | sed 's/<!\[CDATA\[//g; s/\]\]>//g' | clean_html | head -1)
      link=$(echo "$item" | sed -n 's/.*<link>\(.*\)<\/link>.*/\1/p' | head -1)
      
      # Fallback: try guid if no link
      [ -z "$link" ] && link=$(echo "$item" | sed -n 's/.*<guid[^>]*>\(.*\)<\/guid>.*/\1/p' | head -1)
      
      if [ -n "$title" ] && [ -n "$link" ]; then
        echo "• [$title]($link)"
      fi
    done
}

# AP News
echo "**Associated Press**" >> "$TEMP_FILE"
parse_rss "https://rsshub.app/apnews/topics/apf-topnews" 5 >> "$TEMP_FILE" 2>/dev/null
if [ $(tail -1 "$TEMP_FILE" | grep -c "^$") -eq 1 ]; then
  echo "• (Failed to fetch)" >> "$TEMP_FILE"
fi
echo "" >> "$TEMP_FILE"

# Ars Technica
echo "**Ars Technica**" >> "$TEMP_FILE"
parse_rss "https://feeds.arstechnica.com/arstechnica/index" 5 >> "$TEMP_FILE" 2>/dev/null
if [ $(tail -2 "$TEMP_FILE" | head -1 | grep -c "Ars") -eq 1 ]; then
  echo "• (Failed to fetch)" >> "$TEMP_FILE"
fi
echo "" >> "$TEMP_FILE"

# Reuters
echo "**Reuters**" >> "$TEMP_FILE"
parse_rss "https://www.reutersagency.com/feed/?best-topics=tech&post_type=best" 5 >> "$TEMP_FILE" 2>/dev/null
if [ $(tail -2 "$TEMP_FILE" | head -1 | grep -c "Reuters") -eq 1 ]; then
  echo "• (Failed to fetch)" >> "$TEMP_FILE"
fi
echo "" >> "$TEMP_FILE"

# Washington Post
echo "**Washington Post**" >> "$TEMP_FILE"
parse_rss "https://feeds.washingtonpost.com/rss/national" 5 >> "$TEMP_FILE" 2>/dev/null
if [ $(tail -2 "$TEMP_FILE" | head -1 | grep -c "Washington") -eq 1 ]; then
  echo "• (Failed to fetch)" >> "$TEMP_FILE"
fi
echo "" >> "$TEMP_FILE"

# The Hill
echo "**The Hill**" >> "$TEMP_FILE"
parse_rss "https://thehill.com/feed/" 5 >> "$TEMP_FILE" 2>/dev/null
if [ $(tail -2 "$TEMP_FILE" | head -1 | grep -c "The Hill") -eq 1 ]; then
  echo "• (Failed to fetch)" >> "$TEMP_FILE"
fi
echo "" >> "$TEMP_FILE"

# WTOP (DC Local)
echo "**WTOP (DC Local)**" >> "$TEMP_FILE"
parse_rss "https://wtop.com/feed/" 5 >> "$TEMP_FILE" 2>/dev/null
if [ $(tail -1 "$TEMP_FILE" | grep -c "WTOP") -eq 1 ]; then
  echo "• (Failed to fetch)" >> "$TEMP_FILE"
fi

cat "$TEMP_FILE"
