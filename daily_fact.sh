#!/bin/bash
# daily_fact.sh — generates an interesting/obscure fact via Gemma and sends to Telegram

FACT=$(curl -s http://localhost:11434/api/generate \
  -d '{"model":"gemma3:12b","prompt":"Give me one genuinely interesting, obscure, or surprising fact. Keep it to 2-3 sentences max. No intro, just the fact.","stream":false}' \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['response'])")

echo "$FACT

*(via gemma3:12b)*"
