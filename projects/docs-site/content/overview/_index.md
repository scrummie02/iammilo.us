---
title: "Overview"
date: 2026-03-12
weight: 1
---

# System Overview

## Architecture Summary

The Dain Bentley home lab is a self-hosted infrastructure running on a local LAN (`192.168.200.0/24`) consisting of two primary compute nodes, an AI agent stack, a full automation platform, and several Docker-hosted services.

```
Internet
    │
    ▼
[Router / LAN: 192.168.200.0/24]
    │
    ├── cachyos-x8664 (192.168.200.240) ← Primary: MILO lives here
    │       └── OpenClaw Gateway (port 18789)
    │       └── Ollama (Qwen, Gemma local models)
    │       └── NFS client
    │
    ├── OTTO (192.168.200.241) ← Secondary: Worker node
    │       └── OpenClaw Node Host (tunnels to MILO)
    │       └── AMD GPU (ROCm)
    │
    ├── HV01 (192.168.200.220) ← Portainer, Docker host
    │       └── Portainer CE
    │
    ├── HV03 (192.168.200.223) ← Docker host
    │       └── N8N
    │       └── This docs site (Hugo + Nginx)
    │
    └── NFS Server (192.168.200.224) ← Primary backup storage
            └── /data/Backups/cachyos/openclaw/
```

## Key Design Principles

1. **MILO is the single point of contact** — All Telegram messages route through MILO. OTTO is a headless worker.
2. **Two-tier backup** — NFS rsync nightly at 2:00 AM + Google Drive sync at 2:30 AM.
3. **N8N handles scheduled automations** — Traffic, email digests, news, NextDoor filtering. OpenClaw cron is reserved for MILO-specific tasks.
4. **Gemini Pro is the default model** — Cost-efficient. Claude is reserved for sensitive or complex reasoning tasks.
