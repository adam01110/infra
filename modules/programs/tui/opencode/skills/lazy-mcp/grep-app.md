---
name: lazy-mcp-grep-app
description: Use this skill when you need real-world code examples from public GitHub repositories. Search implementation patterns, API usage, error strings, or language-specific examples through grep.app.
mcp:
  grep-app:
    type: remote
    url: https://mcp.grep.app
---

# grep.app Code Search

Use this skill to search real code examples from public GitHub repositories through grep.app.

## When to Use This Skill

Use this skill when the user needs:

- Real-world implementation patterns.
- API usage examples from open-source code.
- Error strings or syntax found in actual repositories.
- Language-specific or repository-specific code examples.

## Workflow

1. Search for a concrete code pattern instead of a generic topic.
2. Narrow the query by language or repository when needed.
3. Reuse the strongest matching pattern for follow-up searches in the same task.

## Usage Rules

- Prefer code-shaped queries such as function names, imports, types, or error strings.
- Use language filters when the user needs examples in a specific ecosystem.
- Use repository filters when the user wants patterns from a known project.
- Treat grep.app as a source of examples, not as authoritative documentation.
