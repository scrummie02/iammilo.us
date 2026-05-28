# MILO Crew — Node Reference

The AI nodes in Dain's OpenClaw setup. Short punchy names, actual acronyms.

## MILO (Gateway)
- **Name:** Mechanical Intelligent Learning Operator
- **Role:** Primary gateway, routing, heartbeat checks
- **Host:** Milo (main OpenClaw instance)
- **Models:** qwen3.5:2b, cloud fallbacks
- **Status:** Always on

## OTTO (Local Node)
- **Name:** Open Terminal Task Operator
- **Role:** General tasks, cloud model access, browser/system work
- **IP:** 192.168.200.241
- **OS:** CachyOS (Linux, x86_64)
- **Models:** kimi-k2.6:cloud, qwen3.5
- **SSH:** dain@192.168.200.241
- **Services:** openclaw-node.service, milo-gateway-tunnel.service

## IGOR (GPU Node)
- **Name:** Intel GPU Operations & Reasoning
- **Role:** Deep reasoning, GPU-accelerated workloads, image generation
- **IP:** 192.168.200.242
- **OS:** CachyOS (Linux, x86_64)
- **GPU:** Intel Arc, 96GB + 64GB memory
- **Models:** gemma4:26b, gemma4:31b, gemma4:e2b, gemma4:e4b
- **SSH:** dain@192.168.200.242

## Notes
- OTTO and IGOR are paired nodes — OTTO handles the day-to-day, IGOR handles the heavy lifting
- All run Ollama locally
- Add future nodes here as the crew grows
