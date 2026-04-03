---
title: "AI Agents"
date: 2026-03-12
weight: 3
---

# AI Agents

## MILO — Primary Agent

**MILO** (Mechanical Intelligent Learning Operator) is the primary AI agent. He runs on `cachyos-x8664` and is the sole point of contact via Telegram.

| Property | Value |
|---|---|
| Host | cachyos-x8664 (192.168.200.240) |
| Telegram | @Milo_theclaw_bot |
| Gateway port | 18789 (loopback) |
| Default model | `google-gemini-cli/gemini-3-pro-preview` |
| Fallback 1 | `google-gemini-cli/gemini-3-flash-preview` |
| Fallback 2 | `anthropic/claude-sonnet-4-6` |
| Fallback 3 | `github-copilot/claude-sonnet-4.6` |
| Workspace | `/home/dain/.openclaw/workspace` |

### Memory System

| File | Purpose |
|---|---|
| `SOUL.md` | MILO's personality and behavior rules |
| `IDENTITY.md` | Name, emoji, vibe |
| `USER.md` | Dain's profile, contacts, business info |
| `AGENTS.md` | Session startup rules, routing, heartbeat |
| `TOOLS.md` | Infrastructure notes (cameras, SSH, TTS) |
| `HEARTBEAT.md` | Periodic check tasks |
| `MEMORY.md` | Long-term curated memory |
| `memory/YYYY-MM-DD.md` | Daily session logs |

### Model Routing

| Task | Model |
|---|---|
| Quick Q&A, facts | `qwen2.5:7b` (Ollama, local) |
| Drafts, summaries | `Gemma3:12b` (Ollama, local) |
| General assistant, tools, email, calendar | `gemini-3-pro-preview` (default) |
| Sensitive emails (Jen/legal), complex reasoning | `claude-sonnet-4-6` |

---

## OTTO — Worker Node

**OTTO** (Operational Task and Tooling Operator) is MILO's headless worker. He has no Telegram channel.

| Property | Value |
|---|---|
| Host | OTTO (192.168.200.241) |
| Role | Background compute, task execution |
| Gateway | Connects to MILO's gateway via SSH tunnel |
| Default model | `google-gemini-cli/gemini-3-pro-preview` |
| Workspace | Synced from MILO (rsync on demand) |

### How MILO Delegates to OTTO

MILO uses `sessions_send` or sub-agents to dispatch tasks to OTTO. OTTO executes, reports back, and MILO relays results to Dain.

OTTO has full access to:
- N8N API
- Gemini API
- SSH tools
- The workspace (synced copy)

---

## Heartbeat System

MILO runs periodic heartbeat checks (every ~1 hour). Tasks defined in `HEARTBEAT.md`:

- Check Gmail inbox for new replies
- Alert Dain if anything noteworthy arrives

OTTO health checks are separate systemd timers:
- `otto-ping.timer` — every 15 minutes
- `otto-stats.timer` — every 30 minutes (CPU + RAM + GPU via Qwen analysis)
