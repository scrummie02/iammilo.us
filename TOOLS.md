# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

Add whatever helps you do your job. This is your cheat sheet.

## Related

- [Agent workspace](/concepts/agent-workspace)


## Reactions
Reactions are enabled for Telegram in MINIMAL mode.
React ONLY when truly relevant:
- Acknowledge important user requests or confirmations
- Express genuine sentiment (humor, appreciation) sparingly
- Avoid reacting to routine messages or your own replies
Guideline: at most 1 reaction per 5-10 exchanges.
## Runtime
Runtime: agent=main | host=Milo | repo=/home/dain/.openclaw/workspace | os=Linux 7.0.1-1-cachyos (x64) | node=v25.5.0 | model=ollama/kimi-k2.6:cloud | default_model=ollama/kimi-k2.6:cloud | shell=fish | channel=telegram | capabilities=inlinebuttons,nativeapprovals | thinking=off
Current model identity: ollama/kimi-k2.6:cloud. If asked what model you are, answer with this value for the current run.
Reasoning: off (hidden unless on/stream). Toggle /reasoning; /status shows Reasoning when enabled.

## Known Issues / Workarounds

### gog Gmail Auth Expired
- OAuth tokens for `gog` expire and require browser re-auth (no headless flow).
- When `gog gmail` commands fail with "No auth", Dain must run `gog auth add dain.bentley@gmail.com --services gmail` manually.
- **Until then**, email-related cron jobs (VIP checks, auto-drafts) are blocked.
- Document failures in daily notes so we don't lose track of auth state.

## ⚠️ CURRENT BLOCKERS (Last updated: 2026-06-09 5:12 PM)
- **gog Gmail auth expired** — VIP email checks failing. Dain needs to re-auth via browser. **CONFIRMED STILL BROKEN — `invalid_grant` on every attempt since June 6. VIP check for julie.a.siegel84@gmail.com also failed at 11:25 AM, 1:55 PM, 4:55 PM, 6:25 PM, 7:40 PM, 8:55 PM, 1:42 AM, 1:55 AM, 7:27 AM, 10:12 AM, 1:57 PM, 3:12 PM, 5:12 PM, and again at 5:27 PM on June 9.**
- **Fleet dashboard refresh** — Last run at 2026-06-09 7:08 AM (cron job `df75fec2-c0b9-4e0c-9a0d-d1d964ff260a`).
