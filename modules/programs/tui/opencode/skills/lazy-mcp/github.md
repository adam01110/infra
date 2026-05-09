---
name: lazy-mcp-github
description: Use this skill when you need GitHub repository data. Query repositories, code, issues, pull requests, commits, branches, releases, workflows, Actions, CI/CD state, collaborators, permissions, or repository metadata.
mcp:
  github:
    command: ["github-mcp-server-wrapper"]
---

# GitHub MCP

Use this skill to query and inspect GitHub data through the GitHub MCP server.

## When to Use This Skill

Use this skill when the user needs:

- Repository metadata or configuration details.
- Source code, trees, files, or commit history.
- Issues, pull requests, reviews, comments, or discussions.
- Branch, release, workflow, or Actions state.
- Collaborator, permission, or repository access information.

## Workflow

1. Identify the owner and repository first.
2. Query the GitHub MCP tool that matches the requested GitHub object.
3. Reuse repository context across follow-up lookups in the same task.

## Usage Rules

- Prefer the GitHub MCP server over memory for repository state and metadata.
- Be explicit about `owner`, `repo`, branch, PR number, issue number, or commit SHA.
- Use read-only inspection workflows unless the user explicitly asks for a write action and the available tools support it.
- Keep follow-up queries scoped to the same repository until the user switches context.
