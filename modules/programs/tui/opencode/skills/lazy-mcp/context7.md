---
name: lazy-mcp-context7
description: Use this skill when you need up-to-date library or framework documentation. Resolve the correct Context7 library ID, then query the docs for APIs, configuration, setup steps, or code generation.
mcp:
  context7:
    command: ["context7-mcp-wrapper"]
---

# Context7 Documentation Search

Use this skill to search current, library-specific documentation through Context7.

## When to Use This Skill

Use this skill when the user needs:

- Library or framework API documentation.
- Setup or configuration steps.
- Version-specific behavior.
- Code generation grounded in current docs.
- Accurate examples for a specific package.

## Workflow

1. Resolve the library ID with `resolve-library-id` when you do not already know it.
2. Query the documentation with `query-docs` using the resolved ID.

If you already know the exact Context7 library ID in `/org/project` format, skip the resolution step.

## Usage Rules

- Prefer Context7 over memory when the answer depends on current library behavior.
- Include the library name, feature, and version in the query when possible.
- Keep queries specific enough to retrieve code and configuration details.
- Use the resolved library ID directly for follow-up lookups in the same task.
