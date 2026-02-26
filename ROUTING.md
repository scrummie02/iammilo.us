# ROUTING.md — Model Routing Rules
# Updated: 2026-02-26

MILO uses multiple models. Always check this file before deciding who handles a task.

## Available Models

| Model | How to call | Best for |
|---|---|---|
| **Claude (me)** | Native (default) | Complex reasoning, personal context, tools, memory |
| **Gemma3:12b** | `ollama_ask gemma3:12b` | Simple tasks (see below) — local, fast, free |
| **qwen2.5:7b** | `ollama_ask qwen2.5:7b` | Ultra-fast one-liners, throwaway drafts |
| **Gemini** | `google-gemini-cli/gemini-3-pro-preview` (OAuth, configured ✅) | Large context, multimodal, Claude fallback |

## Routing Rules (Tiered)

### ⚡ Tier 1 → qwen2.5:7b (local, ~5 sec) for:
- Quick Q&A, definitions, "what is X"
- Unit/currency conversions
- One-liner explanations
- Simple trivia or fun facts
- Very short translations
- Quick yes/no or simple factual lookups

### 🟡 Tier 2 → Gemma3:12b (local, ~45-60 sec) for:
- Summarizing articles or short documents
- Draft emails or messages (first pass)
- Rewrites, grammar fixes, proofreading
- Brainstorming lists (more than 3-5 items)
- Longer translations
- Creative writing (short form)
- Anything where quality matters but stays simple

### 🟧 Tier 3 → Claude (default) for:
- **ALL programming and coding tasks** — no exceptions (debugging, writing code, reviewing code, architecture, scripts, APIs)
- Anything requiring MEMORY.md / USER.md (personal context)
- Multi-step reasoning or complex analysis
- Tasks involving tools (browser, web search, file ops, messaging)
- Professional documents (resume, cover letters, performance reviews)
- Long document analysis
- Sensitive, personal, or nuanced topics
- Job searching, financial analysis, career advice
- Multi-turn conversations requiring full context
- Anything that needs tool use

### 🟦 Tier 4 → Gemini (✅ configured, OAuth via dain.bentley@gmail.com) for:
- Documents/contexts exceeding ~100K tokens
- Image generation or editing
- Tasks where large context window matters
- **Automatic fallback:** if Claude is unavailable/rate-limited, OpenClaw will fall back to `google-gemini-cli/gemini-3-pro-preview` then `google-gemini-cli/gemini-3-flash-preview`

## How to Call Ollama from Shell

```bash
# Quick one-off query
curl -s http://localhost:11434/api/generate \
  -d "{\"model\":\"gemma3:12b\",\"prompt\":\"$PROMPT\",\"stream\":false}" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['response'])"
```

## Notes
- Ollama is running at http://localhost:11434
- Gemma3:12b is the default local model for simple tasks
- qwen2.5:7b is Tier 1 — fast local model for simple tasks
- All Ollama inference is local — nothing leaves the machine
