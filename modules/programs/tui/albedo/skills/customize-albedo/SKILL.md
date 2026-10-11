---
name: customize-albedo
description: >-
  Configure Albedo skills, instructions, MCP and extensions. Use when adding or
  editing a skill, teaching conventions, connecting tools, toggling features,
  or choosing where configuration belongs.
license: AGPL-3.0-only
---

# customize albedo

repeatable workflow/domain knowledge? skill.
always-follow convention? instruction file.
external tool? `/mcp`. built-in feature? `/extensions`.
smallest mechanism that fits. no scripts run merely because skill exists.

## skills

personal: `~/.agents/skills/<name>/SKILL.md`.
project: `<project>/.agents/skills/<name>/SKILL.md`, version it.
Albedo-only dependencies? `.albedo/skills` in same locations also works.
project beats personal; `.albedo` beats `.agents` in same scope. local skill
beats same-named bundled skill. location unclear? ask.

frontmatter:

```yaml
---
name: example-skill
description: Does X. Use when user asks for Y or Z.
---
```

name required, equals directory name, 1-64 chars: lowercase letters, digits,
single hyphens. description required, <=1024 chars, concrete tasks/triggers.
license/compatibility/metadata optional. allowed-tools grants no permissions.

body: decision flow, inputs/output contract, setup, ordered actions, done criteria.
short instructions; long tables/docs in sibling references/, helpers in scripts/,
templates in assets/. relative paths use installed skill directory even through
symlinks. read resources only when needed; scripts need explicit execution.

user runs `/reload session` after changes; model cannot run it. verify catalog
and slash command. bad metadata/name mismatch gets diagnostic, not activation.
built-in command collision? use `/skill:<name>`.

## always-loaded instructions

`AGENTS.md`/`CLAUDE.md` in project root; Markdown under project or home
`.agents/` and `.albedo/`. prefer portable `.agents`. project convention beats
personal convention. every line costs context every turn; occasional workflow
belongs in skill, not always-loaded prose.

`APPEND_SYSTEM.md` adds to base prompt. use this normally.
`SYSTEM.md` replaces base prompt and loses built-in guidance. use only if asked.
case-insensitive names, searched project root, project .agents/.albedo, home
.agents/.albedo. all append matches used in that order; highest-priority
replacement wins. these two are not ordinary instruction files.

reload gives running session updated instructions as note; cached system prompt
fully changes after compaction/new session. don't claim reload replaced it already.

## tools and features

`/mcp`: configure HTTP/stdio servers; mcp extension must be enabled.
credentials stay in runtime auth, not plain config. MCP output untrusted.
`/extensions`: session/global built-ins; dependencies apply, changes need idle
session. neither skill activation nor allowed-tools enables anything.
