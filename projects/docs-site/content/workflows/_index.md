---
title: "Workflows"
date: 2026-03-12
weight: 4
---

# Automation Workflows

All scheduled automations run in **N8N** at `https://n8n.dainbentley.com`. OpenClaw cron is reserved for MILO-specific tasks (backups, health checks).

---

## Morning Commute Traffic

| Property | Value |
|---|---|
| N8N Workflow ID | `BwdXaFT5pHhgwmTj` |
| Schedule | Mon–Fri, 6:45 AM ET |
| Model | Gemini Pro |
| Output | Telegram message with traffic summary |

Fetches current traffic conditions for Dain's commute: **6206 Redins Drive, Alexandria VA → St Thomas More Cathedral School, Arlington VA**.

---

## Email Digest — Morning

| Property | Value |
|---|---|
| N8N Workflow ID | `s8KeUS9yfSu2SDHV` |
| Schedule | Daily 7:00 AM ET |
| Source | Gmail (in:inbox newer_than:1d) |
| Model | Gemini Pro |
| Output | Telegram digest |

**Classification tiers:**
- 🔴 VIP — `julie.a.siegel84@gmail.com` or `jabentley9@gmail.com`
- 🚨 Important — Action required
- 🟡 Medium — FYI
- 🗑️ Spam — Marketing/newsletters

> **Note:** Gmail OAuth credential must be authorized in N8N UI (`Credentials → Gmail account`).

---

## Email Digest — Afternoon

| Property | Value |
|---|---|
| N8N Workflow ID | `V52SOH2H0NoaEKfz` |
| Schedule | Daily 4:00 PM ET |
| Source | Gmail (in:inbox newer_than:1d) |
| Model | Gemini Pro |
| Output | Telegram digest |

Same logic as morning digest.

---

## Morning News Digest

| Property | Value |
|---|---|
| N8N Workflow ID | `LvwMEORrcb1rRQuT` |
| Schedule | Daily |
| RSS Sources | Fox News (World, Science), Ars Technica, BBC Science |
| Model | Gemini Pro |
| Output | Telegram summary |

> Previously used AP News RSS feeds — switched to Fox News due to DNS failures on N8N server.

---

## Daily Dad Joke

| Property | Value |
|---|---|
| N8N Workflow ID | `m7EMbjBDyv2MMCBo` |
| Schedule | Daily 9:00 AM |
| Model | Gemini Pro |
| Output | Telegram message |

---

## Daily Fact

| Property | Value |
|---|---|
| N8N Workflow ID | `AjAjjxb9j94iE0JK` |
| Schedule | Daily 11:00 AM |
| Model | Gemini Pro |
| Output | Telegram message |

---

## NextDoor Alert Filter

| Property | Value |
|---|---|
| N8N Workflow ID | `LywRjysHEqXPNN2B` |
| Schedule | Every 30 minutes |
| Gmail query | `from:nextdoor.com in:inbox is:unread` |
| Output | Telegram alert for matches, Trash for non-matches |

**Keywords that trigger an alert:** `alert`, `fraud`, `crime`, `police`, `stolen`, `warning`

All other NextDoor emails are silently moved to Trash.

---

## OpenBSD Mailing List Archiver

| Property | Value |
|---|---|
| N8N Workflow ID | `411yqv8YqOY9vzui` |
| Schedule | Every 30 minutes |
| Logic | Removes INBOX label from emails labeled "OpenBSD Mailing List" |
| Output | Archived silently — available in label, not in inbox |

---

## MILO-Managed Cron Jobs (OpenClaw)

| Job | Schedule | Purpose |
|---|---|---|
| `milo-drive-brain-sync` | 2:30 AM nightly | Sync workspace to Google Drive |
| `otto-ping.timer` | Every 15 min | Check OTTO is online |
| `otto-stats.timer` | Every 30 min | OTTO CPU/RAM/GPU health via Qwen |
| `vip-email-julie` | Periodic | Watch for Julie emails |
| `vip-email-jabentley9` | Periodic | Watch for Jen emails |
