# ROUTING.md — Model Routing Rules
# Updated: 2026-04-03

MILO uses multiple models. Routing is **automatic** — MILO selects the right model per task.
Dain can override at any time by saying "use Claude", "use Qwen", "use Gemma", etc.

---

## Available Models

| Model | Where | How to call | Best for |
|---|---|---|---|
| **qwen3-vl:4b** | OTTO (192.168.200.241) | `./ollama_ask.sh qwen3-vl:4b` | Fast Q&A, conversions, trivia, image analysis |
| **gemma4:e4b** | OTTO (192.168.200.241) | `./ollama_ask.sh gemma4:e4b` | Drafts, summaries, rewrites, brainstorming |
| **Gemini Flash** | Native (default session) | Default | Tools, personal context, general assistant |
| **Claude Sonnet** | Anthropic | `/model anthropic/claude-sonnet-4-6` | Intense coding, complex reasoning, nuanced logic |

---

## Automatic Routing Rules

### ⚡ Tier 1 → qwen3-vl:4b (~5 sec, OTTO, free)
Call `./ollama_ask.sh qwen3-vl:4b` and relay the response. Use when:
- Quick factual Q&A ("what is X", "who is Y", "when did Z happen")
- Unit/currency conversions
- Simple definitions or trivia
- One-line translations
- Quick yes/no factual lookups
- Simple math
- Image analysis (vision-capable model)

### 🟡 Tier 2 → gemma4:e4b (~20-40 sec, OTTO, free)
Call `./ollama_ask.sh gemma4:e4b` and relay the response. Use when:
- Summarizing articles or short documents (no tools needed)
- First-pass email/message drafts (non-sensitive)
- Rewrites, grammar fixes, proofreading
- Brainstorming lists
- Short creative writing
- Longer translations

### 🟧 Tier 3 → Gemini Flash (me, default)
Handle directly as the default model. Always use Gemini for:
- General assistant tasks (file ops, messaging, basic terminal commands)
- Anything needing tools (browser, Gmail, web search)
- Personal context (USER.md, MEMORY.md, Dain's life/relationships/work)
- Professional documents (resume, cover letters, performance reviews)
- Heavy reading, document analysis, and large context windows

### 🟦 Tier 4 → Claude Sonnet (coding / nuanced logic)
Call via `/model anthropic/claude-sonnet-4-6` or ask me to switch. Use Claude exclusively for:
- **ALL intense coding and programming** — building new apps, deep debugging, complex architecture
- Highly sensitive, nuanced, or emotional topics where tone is critical
- Multi-step complex logical reasoning

---

## Response Attribution
Always note the model when relaying a non-primary response, e.g.:
> Austin. *(via qwen3-vl:4b)* ⚡

Format: `*(via <model>)*` at the end of the response.

---

## Override Commands (Dain can say at any time)

| Dain says | MILO does |
|---|---|
| "use Claude for this" | Route current task to Claude |
| "use Qwen" | Route to qwen3-vl:4b |
| "use Gemma" | Route to gemma4:e4b |
| "use Gemini" | Route to Gemini |
| "always use Claude" | Pin Claude for rest of session |
| "back to auto" | Resume automatic routing |

---

## Shell Helper

```bash
./ollama_ask.sh <model> "your prompt"
# Examples:
./ollama_ask.sh qwen3-vl:4b "What is the capital of France?"
./ollama_ask.sh gemma4:e4b "Summarize this in 3 bullet points: ..."
```

## Notes
- Ollama endpoint: OTTO at http://192.168.200.241:11434
- All local inference stays on-machine (private, no API cost)
- IGOR (GMKtec Ultra 9, 96GB DDR5) — planned for Qwen3.5-27B-Claude-distilled; not yet online
- When IGOR comes online, update endpoint and add the 27B model as a new Tier 2/3
