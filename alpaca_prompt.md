# Alpaca Development Prompt

You are building **Alpaca** — a privacy-first, local-first AI co-worker app for Ollama.

## Core Concept
Alpaca is a desktop application that lets users delegate tasks to local AI models (via Ollama) and get actual deliverables, not just chat. Think Copilot Cowork or Claude Cowork, but running entirely on your hardware with open-weight models.

## Key Design Decisions
- **Core Engine: Rust** — compiled binary, zero-cost abstractions, native Ollama integration via `ollama-rs` crate
- **UI Layer: Tauri** — native desktop app with web frontend (smaller footprint than Electron)
- **Database: SQLite** — local-first, single file, zero dependencies
- **Connector Scripts: Node.js (optional)** — reuse existing gog skill logic for Gmail/GDrive, rapid prototyping

## Architecture
```
User Device (Alpaca App)
    ├── Local Ollama Instance
    │   ├── qwen3.5:2b — quick tasks
    │   ├── gemma4:26b/31b — deep reasoning
    │   └── Custom models
    ├── Connectors (local execution)
    │   ├── Filesystem
    │   ├── Gmail/GDrive
    │   └── IMAP/SMTP
    └── Optional: Cloud Ollama (for heavy tasks)
```

## Task Execution Flow
1. **Delegate** — User describes outcome they want
2. **Plan** — Alpaca breaks it into steps
3. **Execute** — Runs in background with checkpoints
4. **Review** — User approves/modifies before finalization
5. **Deliver** — Completed task with deliverables

## MVP Phase 1 Connectors
- Local filesystem (read/write files, organize folders)
- Google Drive / Gmail (via gog skill integration)
- Generic IMAP/SMTP (any email provider)

## Your Task
1. Initialize a Rust + Tauri project structure
2. Implement the core task delegation loop (delegate → plan → execute → review → deliver)
3. Build a basic filesystem connector
4. Create a simple UI for task input and status tracking
5. Add SQLite schema for tasks, checkpoints, and preferences
6. Implement Ollama integration (list models, send prompts, stream responses)
7. Write tests for core functionality
8. Create a README with setup instructions
9. Push everything to GitHub

## Deliverables
- Working Rust/Tauri codebase
- SQLite schema and migrations
- Basic filesystem connector
- Simple task UI
- Tests
- README with setup instructions
- GitHub repo URL

Start building. Report progress as you go.