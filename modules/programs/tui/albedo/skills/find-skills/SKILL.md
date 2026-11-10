---
name: find-skills
description: >-
  Use when the user wants a new agent capability, asks whether a skill exists,
  or requests an installable skill for a specialized workflow.
license: AGPL-3.0-only
compatibility: Requires Bun and network access to skills.sh.
metadata:
  author: Adam0
  version: "1.0.0"
  short-description: Find and assess installable agent skills
allowed-tools: bash web_search fetch_content
---

# find skills

When the user wants a skill, tool, workflow, or new capability, search the
installable skills.

CLI: `comma bunx skills`. Browse: <https://skills.sh/>.

## Flow

1. Identify the domain and exact task. Common tasks likely have an existing
   skill.
2. Check the skills.sh leaderboard first.
3. Search specific terms: `react performance`, `pr review`, `changelog`.
4. If results are weak, try synonyms (`deploy`, `deployment`, `ci-cd`) and
   inspect popular sources such as `vercel-labs/agent-skills` and
   `ComposioHQ/awesome-claude-skills`.
5. Check quality before recommending. Prefer 1K+ installs, a reputable source
   (`vercel-labs`, `anthropics`, `microsoft`), and meaningful stars and
   activity. Treat under 100 installs or stars with caution.
6. Present the name, purpose, install count and source, exact install command,
   and skills.sh link.
7. Let the user choose first; only then offer installation.

```bash
comma bunx skills find <query>
comma bunx skills add <owner/repo@skill> -g -y
comma bunx skills check
comma bunx skills update
```

Useful categories: web, testing, DevOps, docs, review/refactor,
design/accessibility, automation/git.

If no relevant skill exists, say so and offer to handle the task directly. If a
reusable custom skill would likely help, mention `comma bunx skills init`.
