---
name: lazy-mcp-authentik
description: Use this skill when you need to inspect or administer Authentik users, groups, applications, flows, providers, events, tokens, or system health through the Authentik MCP server.
mcp:
  authentik:
    command: ["authentik-mcp-wrapper"]
---

# Authentik MCP

Use this skill to query and administer Authentik through the Authentik MCP server.

## When to Use This Skill

Use this skill when the user needs:

- User, group, or application management.
- Authentik event and audit inspection.
- Flow, provider, token, or system health details.
- Authentik configuration diagnostics or automation.

## Workflow

1. Identify the Authentik object type and exact target first.
2. Prefer read-only inspection before making changes.
3. Use write operations only when the user explicitly asks for an Authentik change.

## Usage Rules

- Be explicit about names, IDs, slugs, or filters before calling tools.
- Confirm destructive operations before invoking delete or revoke actions.
- Keep follow-up queries scoped to the same Authentik object until the user switches context.
