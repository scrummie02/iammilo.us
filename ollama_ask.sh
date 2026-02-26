#!/bin/bash
# Usage: ollama_ask.sh <model> <prompt>
MODEL="${1:-qwen3.5:35b}"
PROMPT="$2"
curl -s http://localhost:11434/api/generate \
  -d "{\"model\":\"$MODEL\",\"prompt\":$(echo "$PROMPT" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))"),\"stream\":false}" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['response'])"
