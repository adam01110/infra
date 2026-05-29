---
name: find-skills
description: Use this skill when the user is looking for functionality that might exist as an installable skill. Search for relevant skills, verify their quality, and present the best options with install commands.
---

# Find Skills

Use when the user asks for a skill/tool/workflow, wants new agent capability, or asks whether a specialized task can be handled by an installable skill.

CLI: `comma bunx skills`
Browse: <https://skills.sh/>

Commands:

- `comma bunx skills find <query>`: search skills.
- `comma bunx skills add <owner/repo@skill> -g -y`: install globally without prompts.
- `comma bunx skills check`: check updates.
- `comma bunx skills update`: update installed skills.

Workflow:

1. Identify domain, task, and whether it is likely common.
2. Check <https://skills.sh/> leaderboard for popular known skills before CLI search.
3. Search with specific keywords: `react performance`, `pr review`, `changelog`, etc.
4. Verify before recommending: prefer 1K+ installs, reputable sources (`vercel-labs`, `anthropics`, `microsoft`), and repos with meaningful stars/activity. Treat <100 installs or <100 stars cautiously.
5. Present skill name, purpose, install count/source, install command, and skills.sh link.
6. Offer installation only after the user chooses.

If results are weak, try alternate terms like `deploy`/`deployment`/`ci-cd` and check popular sources such as `vercel-labs/agent-skills` and `ComposioHQ/awesome-claude-skills`.

Search categories: web, testing, DevOps, docs, review/refactor, design/accessibility, automation/git.

If no relevant skill exists, say so, offer to handle the task directly, and mention `comma bunx skills init` only if the user may want a reusable custom skill.
