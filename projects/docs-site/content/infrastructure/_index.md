---
title: "Infrastructure"
date: 2026-03-12
weight: 2
---

# Infrastructure

## Nodes

| Hostname | IP | OS | Role |
|---|---|---|---|
| cachyos-x8664 | 192.168.200.240 | CachyOS (Linux x86_64) | Primary — MILO's home |
| OTTO | 192.168.200.241 | CachyOS (Linux x86_64) | Worker node |
| HV01 | 192.168.200.220 | — | Docker host, Portainer |
| HV03 | 192.168.200.223 | — | Docker host (N8N, Docs) |
| NFS Primary | 192.168.200.224 | — | Backup storage |
| NFS Secondary | 192.168.200.226 | — | Replicated backup |

---

## OTTO (Worker Node)

OTTO is a headless AI worker node managed by MILO. It has no Telegram channel.

**Setup:**
- OpenClaw `node` service connects to MILO's gateway via an SSH tunnel
- Tunnel: `milo-gateway-tunnel.service` on OTTO forwards `localhost:18790` → `192.168.200.240:18789`
- SSH key-based auth between MILO and OTTO (no password required)

**Monitoring:**
- Ping check every 15 minutes (`otto-ping.timer`)
- Stats check every 30 minutes (`otto-stats.timer`) — CPU, RAM, AMD GPU via `rocm-smi`, analyzed by Qwen
- Alerts sent to Telegram if anomalies detected or node goes offline

**GPU:**
- AMD GPU with ROCm support
- Monitoring tool: `rocm-smi` (installed via `pacman`)

---

## Backup Strategy

| Layer | Method | Schedule | Destination |
|---|---|---|---|
| Primary NFS | `rsync` | ~2:00 AM nightly | `192.168.200.224:/data/Backups/cachyos/openclaw/` |
| Secondary NFS | Auto-replicated | Continuous | `192.168.200.226` (same path) |
| Google Drive | `drive_sync_brain.sh` | 2:30 AM nightly | `AI/MILO/Core/` and `AI/MILO/Memory/` |

**Google Drive Structure:**
```
AI/
└── MILO/
    ├── Core/     ← SOUL.md, IDENTITY.md, USER.md, AGENTS.md, TOOLS.md, HEARTBEAT.md
    └── Memory/   ← Daily session logs (memory/YYYY-MM-DD.md)
```

---

## SSH Access

All SSH connections from MILO to OTTO use key-based authentication.

- MILO public key → OTTO `~/.ssh/authorized_keys`
- OTTO public key → MILO `~/.ssh/authorized_keys` (for reverse tunnel)

To connect manually:
```bash
ssh dain@192.168.200.241
```
