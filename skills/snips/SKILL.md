---
name: snips
description: "Load persistent context snippets (snips) from markdown reference files. Use when the user mentions a snip name, asks about stored context, or says things like 'load my [name] snip', 'check my [name] snip', 'what do I have in [name]', or references any topic covered by a stored snip. Also use when the user asks for context they previously saved to avoid repeating themselves."
---

# Snips — Persistent Context Snippets

## Overview

Snips are markdown reference files that store persistent context. Each snip is a standalone markdown file in `references/` that Codex loads on demand when relevant.

Think of them like Gemini Gems or custom GPT instructions — save context once, reference it forever.

## How It Works

1. Each `.md` file in `references/` = one snip
2. When a user mentions a snip by name or topic, load the matching reference file
3. Apply that context to the current task

## Snip Naming Convention

Files in `references/` follow `topic-name.md` (kebab-case). When matching:
- Exact name matches: "load my business snip" → `references/business.md`
- Partial/topic matches: "notary stuff" → `references/business.md` (if it contains notary info)
- Ask user which snip if ambiguous

## Instructions

When user mentions loading, checking, or using a snip:
1. Identify which snip(s) they want
2. Read the matching `references/*.md` file(s)
3. Confirm loaded context briefly (1-2 lines)
4. Proceed with their request using that context

When user wants to create/update a snip:
1. Determine a clear, kebab-case filename
2. Write their context to `references/<name>.md`
3. Confirm the snip is saved

## Available Snips

Check `references/` directory to see what's stored. Common topics might include:
- Business info, workflows, client details
- Personal preferences, project context
- Recurring instructions the user doesn't want to repeat

## Resources

- `references/`: Markdown context files (one per snip)
