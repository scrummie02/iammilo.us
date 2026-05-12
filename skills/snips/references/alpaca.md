# Alpaca — Privacy-First AI Co-worker for Ollama

## Overview
Building a cowork-style app for Ollama called **Alpaca** — privacy-focused, local-first AI coworker that takes action, not just chats. Think of it as your own personal Copilot Cowork, but running entirely on your hardware with open-weight models.

## Name Origin
**Alpaca** = LLaMA + Ollama reference. Friendly, approachable, local.

## Reference Products Analyzed

### Microsoft Copilot Cowork
- **Launch:** March 9, 2026 (Wave 3 of Microsoft 365 Copilot)
- **Core Concept:** Cloud-based AI agent that completes work across M365 apps (Outlook, Teams, Excel, PowerPoint, Word, SharePoint)
- **Key Feature:** Delegates complex multi-step tasks that run in background with checkpoints and progress tracking
- **Integration:** Uses Anthropic Claude tech (Claude Opus 4.7) under the hood via licensed harness/SDK
- **Context Engine:** "Work IQ" — draws signals across all M365 apps for grounded execution
- **Security:** Runs within M365 tenant security/governance boundaries; all actions auditable
- **Pricing:** Requires M365 Copilot license ($30/user/month); E7 bundle at $99/user/month includes Copilot + Agent 365 + Entra Suite
- **Access:** Research Preview → Frontier program (late March 2026)
- **Agent Store:** Users add "Cowork (Frontier)" agent to their Copilot environment

#### Copilot Cowork UI/UX Patterns
- **Objective-driven input:** Users describe outcomes, not tasks (e.g., "Prepare for tomorrow's executive review" vs "Write this report")
- **Task cards/checkpoints:** Visible progress steps with incremental outputs
- **Approval gates:** Sensitive actions require explicit user approval before applying changes
- **Background execution:** Tasks continue while user does other work; checks in if clarification needed
- **Multi-app coordination:** Single workflow produces deliverables across multiple apps simultaneously
- **Intervention points:** Users can interrupt, redirect, pause, or add instructions mid-execution
- **Conversation pane:** Shows execution steps, generated outputs, proposed actions for approval

#### Copilot Cowork Architecture (Anthropic Harness)
Microsoft licensed Anthropic's middle-tier "harness" — the agentic runtime that wraps the model. Key architectural patterns from the leaked Claude Code source (512K lines TypeScript):

1. **Memory as hint, not truth:** Three-tier memory — lightweight MEMORY.md index (150 chars/line) + topic files fetched on demand + raw transcripts grep'd for identifiers. Agent must re-verify cached facts.
2. **autoDream:** Background subsystem (modeled after REM sleep) that runs every 24h or on demand. Prunes outdated entries, merges duplicates, refreshes stale info, synthesizes learnings into structured memory. Tentative observations get promoted to assertions.
3. **KAIROS daemon:** Always-on background daemon that decides when to act (not on schedule). Receives periodic ticks, 15-second blocking budget. Actions written to append-only audit log.
4. **Tool-call orchestration + sub-agent forking:** Sub-agents spawned as tool calls. Parent creates byte-identical copy sharing KV cache. Parallelism nearly free in token cost. Flat orchestration — simple loop, sophisticated tooling.
5. **Two-mind permission model:** Model decides what to attempt; separate tool system decides what's permitted. Permission checks run by cheapest model (Claude Haiku) as cascading classifier. Intent and authorization are architecturally separated.
6. **MCP + lazy tool discovery:** Model Context Protocol standard. Only tool names loaded at session start; search mechanism discovers relevant tools when needed. Scales to hundreds of tools without context blowout.
7. **Three-stage context compaction:** Stage 1 truncates cached tool outputs; Stage 2 generates 20K-token summary at context limit; Stage 3 compresses full conversation + adds recently accessed files (5K tokens/file), active plans, skills.

#### Copilot Cowork vs Claude Cowork
| Aspect | Copilot Cowork | Claude Cowork |
|--------|---------------|---------------|
| Location | Cloud (M365 tenant) | Desktop (Mac/Windows) |
| Data access | M365 graph (emails, Teams, calendar, SharePoint) | Local files + MCP connectors |
| Security | M365 Entra/Purview governance | Folder-level sandboxing |
| Target | Enterprise (Fortune 500) | Individuals, small teams, power users |
| Pricing | $30+/user/month | $20/month (Claude Pro) |
| Strength | Deep M365 integration | Flexibility, custom workflows |

#### Copilot Cowork Use Cases (Official Examples)
1. **Calendar Triage:** Reviews calendar, identifies conflicts/low-value meetings, proposes changes (reschedule/decline/focus blocks)
2. **Meeting Prep:** Pulls relevant emails/files, schedules prep time, produces briefing doc + supporting analysis + client-ready deck
3. **Deep Research:** Gathers earnings reports, SEC filings, analyst commentary, news → organized findings with citations into executive summary + research memo + Excel workbook
4. **Launch Planning:** Builds competitive comparison in Excel, distills value proposition doc, generates pitch deck, outlines milestones and owners

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
- [x] Research competitor products (Copilot Cowork, Claude Cowork, Codex)
- [ ] Define core architecture
- [ ] Build prototype connector system
- [ ] Implement basic task delegation loop
- [ ] Design UI (desktop app, web interface)

### What We Need to Replicate from Copilot Cowork
1. **Objective-driven UI:** User describes outcome, not step-by-step tasks
2. **Background execution:** Tasks run without blocking user; progress visible
3. **Checkpoint system:** Clear progress points where user can review/intervene
4. **Approval gates:** Sensitive actions need explicit user sign-off
5. **Multi-connector coordination:** Single workflow touches multiple apps/services
6. **Memory/context management:** Ground actions in user's actual work data
7. **Audit trail:** All actions logged, user can review what happened
8. **Intervention:** User can pause, redirect, or add mid-task instructions

### Alpaca Differentiators vs Copilot Cowork
- **Local-first:** Runs on your hardware, not in Microsoft's cloud
- **No M365 required:** Works with any email, files, calendar (not locked to Microsoft)
- **No subscription:** Free with local models; optional cloud only when needed
- **Privacy:** Your data never leaves your network
- **Model-agnostic:** Any Ollama model, not locked to Claude/GPT
- **Open source:** Auditable, extensible, community-driven

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
