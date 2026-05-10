# Ollama Co-worker Snip

## Overview
Config and notes for my local Ollama instances — model routing, performance tips, and which models do what.

## Current Models

### MILO (Primary)
- **Model:** qwen3.5:2b
- **Role:** Quick Q&A, simple tasks, heartbeat checks
- **Speed:** Fast, runs 24/7
- **Provider:** Local Ollama

### OTTO (Secondary)
- **Models:** kimi-k2.6:cloud, qwen3.5
- **Role:** General tasks, cloud model access
- **Provider:** Local Ollama

### IGOR (Deep Reasoning)
- **Models:** gemma4:26b, gemma4:31b
- **Role:** Complex logic, deep reasoning, GPU tasks
- **Use when:** Hard problems, multi-step reasoning, GPU workloads

### Gemini (Drafts/Summaries)
- **Model:** gemma4:e2b
- **Role:** Drafts, summaries, rewrites, image analysis
- **Provider:** Local Ollama

### Backup
- **Model:** gemma4:e4b
- **Role:** Lightweight backup
- **Use when:** Primary models down

## Model Routing Rules (from ROUTING.md)

| Task | Model |
|------|-------|
| Quick Q&A, facts, conversions | qwen3.5:2b (MILO) |
| Drafts, summaries, image analysis | gemma4:e2b (IGOR) |
| Personal context, tools, files | qwen3.5:2b |
| Deep reasoning, complex logic | gemma4:26b / gemma4:31b (IGOR) |
| Cloud fallback (long context) | qwen3.5:397b-cloud |
| Backup / lightweight | gemma4:e4b |

## Ollama CLI Tips

```bash
# List running models
ollama ps

# Pull a new model
ollama pull qwen3.5:2b

# Run interactive
ollama run qwen3.5:2b

# List all local models
ollama list
```

## Node Info

### OTTO (Local Node)
- **IP:** 192.168.200.241
- **OS:** CachyOS
- **Models:** kimi-k2.6:cloud, qwen3.5
- **SSH:** dain@192.168.200.241

### IGOR (GPU Node)
- **IP:** 192.168.200.242
- **OS:** CachyOS
- **Models:** gemma4:26b, gemma4:31b
- **Role:** GPU-accelerated deep reasoning
- **SSH:** dain@192.168.200.242

## Troubleshooting

- Model not loading? Check `ollama ps` and restart service
- Slow responses? Check GPU usage on IGOR node
- Token limits? Switch to cloud models for long context

## Notes
- Add new models as they become available
- Keep model list updated as routing rules change
- Monitor which models perform best for each task type

## Alpaca Project

### Overview
Building a cowork-style app for Ollama called **Alpaca** — privacy-focused, local-first AI coworker that takes action, not just chats.

### Reference Products
- **Microsoft Copilot Cowork** — delegates tasks across 365 apps, runs in background with checkpoints, integrates Claude tech
- **Anthropic Claude Cowork** — desktop agent for non-technical workers, handles files/folders/apps autonomously
- **OpenAI Codex** — coding agent with worktrees, cloud environments, multi-agent workflows

### Alpaca Design Goals
- **Privacy-first:** All data stays local, no cloud required (optional Ollama cloud for heavy tasks)
- **Open-weight models:** Gemma family (Gemma 3, future Gemma 4) via Ollama
- **Action-oriented:** From chat to execution — delegate tasks, get deliverables
- **Connectors:**
  - Google Drive / Gmail (via gog skill)
  - Generic IMAP/SMTP support
  - OneDrive (optional)
  - Local filesystem
- **Multi-instance:** Use local Ollama + cloud Ollama instances as needed

### Key Differences from Existing Cowork Tools
- No vendor lock-in — runs on your hardware
- No subscription required — use local models for free
- No data leaves your network unless you choose cloud Ollama
- Open source — hackable, extensible

### Status
- In planning/early design phase
- Name: Alpaca (LLaMA + Ollama reference, friendly)
- Target: Knowledge workers who want AI execution without cloud dependency
