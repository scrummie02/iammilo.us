# ROUTING.md — Model Routing Rules
# Updated: 2026-02-26

MILO uses multiple models. Routing is **automatic** — MILO selects the right model per task.
Dain can override at any time by saying "use Claude", "use Qwen", "use Gemma", etc.

---

## Available Models

| Model | How to call | Best for |
|---|---|---|
| **qwen2.5:7b** | `./ollama_ask.sh qwen2.5:7b` | Fast factual Q&A, conversions, one-liners |
| **Gemma3:12b** | `./ollama_ask.sh gemma3:12b` | Drafts, summaries, rewrites, brainstorming |
| **Claude** | Native (default session) | Tools, personal context, coding, complex tasks |
| **Gemini** | `google-gemini-cli/gemini-3-pro-preview` | Large context, images, Claude fallback |

---

## Automatic Routing Rules

### ⚡ Tier 1 → qwen2.5:7b (~5 sec, local, free)
Call `./ollama_ask.sh qwen2.5:7b` and relay the response. Use when:
- Quick factual Q&A ("what is X", "who is Y", "when did Z happen")
- Unit/currency conversions
- Simple definitions or trivia
- One-line translations
- Quick yes/no factual lookups
- Simple math

### 🟡 Tier 2 → Gemma3:12b (~45-60 sec, local, free)
Call `./ollama_ask.sh gemma3:12b` and relay the response. Use when:
- Summarizing articles or short documents (no tools needed)
- First-pass email/message drafts (non-sensitive)
- Rewrites, grammar fixes, proofreading
- Brainstorming lists
- Short creative writing
- Longer translations

### 🟧 Tier 3 → Claude (me, default)
Handle directly. Always use Claude for:
- **ALL coding and programming** — no exceptions
- Anything needing tools (browser, Gmail, web search, file ops, messaging)
- Personal context (USER.md, MEMORY.md, Dain's life/relationships/work)
- Multi-step reasoning or complex analysis
- Professional documents (resume, cover letters, performance reviews)
- Sensitive, nuanced, or emotional topics
- Career advice, financial analysis, job searching
- Multi-turn conversations needing full context
- Anything with memory or continuity

### 🟦 Tier 4 → Gemini (fallback / large context)
- Documents exceeding ~100K tokens
- Image analysis or generation
- Automatic fallback if Claude is rate-limited

---

## Override Commands (Dain can say at any time)

| Dain says | MILO does |
|---|---|
| "use Claude for this" | Route current task to Claude |
| "use Qwen" | Route to qwen2.5:7b |
| "use Gemma" | Route to Gemma3:12b |
| "use Gemini" | Route to Gemini |
| "always use Claude" | Pin Claude for rest of session |
| "back to auto" | Resume automatic routing |

---

## Shell Helper

```bash
./ollama_ask.sh <model> "your prompt"
# Example:
./ollama_ask.sh qwen2.5:7b "What is the capital of France?"
./ollama_ask.sh gemma3:12b "Summarize this in 3 bullet points: ..."
```

## Notes
- Ollama endpoint: http://localhost:11434
- All local inference stays on-machine (private, no API cost)
- Qwen2.5:7b replaced llama3.2:3b as Tier 1 (better quality, same speed)
- Gemini OAuth: dain.bentley@gmail.com (needs full auth setup)
