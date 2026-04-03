#!/bin/bash
# Usage: ollama_ask.sh <model> <prompt>
# Ollama endpoint: OTTO (192.168.200.241:11434)
MODEL="${1:-gemma4:e4b}"
PROMPT="$2"
curl -s http://192.168.200.241:11434/api/generate \
  -d "{\"model\":\"$MODEL\",\"prompt\":$(echo "$PROMPT" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))"),\"stream\":false}" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['response'])"
