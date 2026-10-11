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

user wants skill, tool, workflow, or new capability? search installable skills.

cli: `comma bunx skills`. browse: <https://skills.sh/>.

## flow

1. identify domain and exact task. common task? likely existing skill.
2. check skills.sh leaderboard first.
3. search specific terms: `react performance`, `pr review`, `changelog`.
4. weak result? try synonyms: `deploy`, `deployment`, `ci-cd`; inspect popular
   sources such as `vercel-labs/agent-skills`,
   `ComposioHQ/awesome-claude-skills`.
5. verify quality before recommendation. prefer 1K+ installs, reputable source
   (`vercel-labs`, `anthropics`, `microsoft`), meaningful stars and activity.
   under 100 installs or stars? caution.
6. present name, purpose, install count/source, exact install command, skills.sh
   link.
7. user chooses first. only then offer installation.

```bash
comma bunx skills find <query>
comma bunx skills add <owner/repo@skill> -g -y
comma bunx skills check
comma bunx skills update
```

useful categories: web, testing, DevOps, docs, review/refactor,
design/accessibility, automation/git.

no relevant skill? say so. offer direct handling. reusable custom skill likely
useful? mention `comma bunx skills init`.
