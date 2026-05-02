#!/bin/bash
# Wrapper to post morning news to Discord via OpenClaw

# Add npm global bin to PATH
export PATH="/home/dain/.npm-global/bin:$PATH"

HEADLINES=$(/home/dain/.openclaw/workspace/scripts/morning-news.py)

# Post to Discord using openclaw CLI
/home/dain/.npm-global/bin/openclaw message send \
  --channel discord \
  --target "1496187939552628826" \
  --message "$HEADLINES"
