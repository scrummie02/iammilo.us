# Alpaca — Privacy-First AI Co-worker for Ollama

## Overview
Building a cowork-style app for Ollama called **Alpaca** — privacy-focused, local-first AI coworker that takes action, not just chats. Think of it as your own personal Copilot Cowork, but running entirely on your hardware with open-weight models.

## Name Origin
**Alpaca** = LLaMA + Ollama reference. Friendly, approachable, local.

## Reference Products Analyzed

### Microsoft Copilot Cowork
- Delegates tasks across Microsoft 365 apps
- Runs in background with checkpoints and progress tracking
- Integrates Anthropic Claude tech under the hood
- Enterprise security and governance boundaries
- Requires Microsoft 365 subscription

### Anthropic Claude Cowork
- Desktop agent for non-technical knowledge workers
- Handles files, folders, and applications autonomously
- Takes a goal and produces deliverables without step-by-step prompting
- Available on paid Claude plans
- Cloud-dependent

### OpenAI Codex
- Coding agent with multi-agent workflows
- Built-in worktrees and cloud environments
- Agents work in parallel across projects
- Automations for routine tasks (issue triage, CI/CD)
- Subscription required

## Alpaca Design Goals

### Core Principles
- **Privacy-first:** All data stays local by default
- **No vendor lock-in:** Runs on your hardware, your rules
- **Open-weight models:** Gemma family (Gemma 3, future Gemma 4) via Ollama
- **Optional cloud:** Ollama cloud instances available for heavy tasks, but not required
- **Action-oriented:** From chat to execution — delegate tasks, get deliverables

### Key Differentiators
| Feature | Alpaca | Copilot/Claude/Codex |
|---------|--------|---------------------|
| Data privacy | Stays on your network | Cloud processed |
| Cost | Free (local models) | Subscription required |
| Vendor lock-in | None | Microsoft/Anthropic/OpenAI |
| Model choice | Any Ollama model | Vendor specific |
| Open source | Yes | No |
| Cloud optional | Yes | Required |

## Connectors & Integrations

### Phase 1 (MVP)
- **Local filesystem** — read/write files, organize folders
- **Google Drive / Gmail** — via existing gog skill integration
- **Generic IMAP/SMTP** — any email provider

### Phase 2
- **OneDrive** — Microsoft cloud storage
- **Calendar** — Google Calendar, Outlook
- **Slack/Discord** — team communication

### Phase 3
- **Custom connectors** — extensible plugin system
- **API endpoints** — webhooks for external services

## Architecture

### Local-First Design
```
User Device (Alpaca App)
    ├── Local Ollama Instance (default)
    │   ├── MILO (qwen3.5:2b) — quick tasks
    │   ├── IGOR (gemma4:26b/31b) — deep reasoning
    │   └── Custom models
    ├── Connectors (local execution)
    │   ├── Filesystem
    │   ├── Gmail/GDrive (via gog)
    │   └── IMAP/SMTP
    └── Optional: Cloud Ollama (for heavy lifting)
```

### Task Execution Flow
1. **Delegate** — User describes outcome they want
2. **Plan** — Alpaca breaks it into steps
3. **Execute** — Runs in background with checkpoints
4. **Review** — User approves/modifies before finalization
5. **Deliver** — Completed task with deliverables

## Model Routing

| Task Type | Local Model | Cloud Fallback |
|-----------|-------------|----------------|
| Quick Q&A, chat | qwen3.5:2b (MILO) | — |
| File organization, drafts | gemma4:e2b | — |
| Deep research, complex logic | gemma4:26b/31b (IGOR) | qwen3.5:397b-cloud |
| Long context tasks | gemma4:31b | ollama cloud |
| Image analysis | gemma4:e2b | — |

## Development Status

### Current Phase: Planning / Early Design
- [ ] Define core architecture
- [ ] Build prototype connector system
- [ ] Implement basic task delegation loop
- [ ] Design UI (desktop app, web interface)

### Tech Stack Decision
**Core Engine: Rust**
- Compiled binary — single file deployment, no runtime overhead
- Zero-cost abstractions — fast enough to run alongside Ollama locally
- Memory safety without GC — predictable performance
- Cross-platform compilation (Windows, macOS, Linux)
- Native Ollama integration via `ollama-rs` crate
- Fits privacy-first promise — auditable, no hidden dependencies

**UI Layer: Tauri (Rust-based)**
- Native desktop app using web frontend (React/Vue/Svelte)
- Smaller footprint than Electron
- Same Rust core, web UI for flexibility
- Alternative: Iced (pure Rust GUI) if avoiding web stack entirely

**Connector Scripts: Node.js (optional)**
- Reuse existing gog skill logic for Gmail/GDrive
- Rapid prototyping for new connectors
- Isolated processes — if Node fails, core engine stays up

**Why not Node for core?**
- Runtime overhead competes with Ollama for resources
- `node_modules` distribution is messy for end users
- Slower startup — compiled Rust is instant
- Harder to audit for privacy claims

**Database: SQLite (local-first)**
- Zero external dependencies
- Single file storage
- Full SQL support for task history, connectors, preferences

### Future Roadmap
- [ ] Multi-agent workflows (parallel execution)
- [ ] Background automation (scheduled tasks)
- [ ] Team sharing (local network collaboration)
- [ ] Mobile companion app

## Target Users
Knowledge workers who want AI execution without cloud dependency:
- Privacy-conscious professionals
- Small business owners
- Developers who want local AI
- Anyone tired of SaaS subscriptions

## Resources
- Ollama: https://ollama.com
- Gemma models: https://ai.google.dev/gemma
- Reference: ollama-cowork.md (infrastructure details)
