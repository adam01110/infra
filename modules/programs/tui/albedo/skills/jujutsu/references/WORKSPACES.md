# Parallel workspaces

Assumes jj 0.44.0. When several agents need one repo, give each its own `@`
with `jj workspace`; the store and op log stay shared.

## Directory decision

Use the first that applies, in this order:

1. `.workspaces/`
2. `workspaces/`
3. Repo instructions such as `AGENTS.md` or `CLAUDE.md`
4. Ask the user

There is no blanket sibling-directory rule.

Before creating a workspace, keep its metadata out of git:

```bash
grep -E '^\.?workspaces/?$' .gitignore 2>/dev/null
```

If missing, ignore the chosen directory before creating the workspace, using
the describe-first workflow from [`NEW_CHANGE.md`](NEW_CHANGE.md). Do not skip
this.

Use a descriptive name:

```bash
REPO_NAME=$(basename "$(jj workspace root)")
WORKSPACE_PATH=".workspaces/${REPO_NAME}-<purpose>"
jj workspace add "$WORKSPACE_PATH"
cd "$WORKSPACE_PATH"
```

Avoid `tmp`, `wip`, `new`. Each workspace gets its own working-copy commit and
`<workspace-name>@` marker; snapshots affect only its `@`.

## Bootstrap

Hand off only after the required environment setup:

| marker | command |
|---|---|
| `package.json` | `npm install` |
| `Cargo.toml` | `cargo build` |
| `pyproject.toml` | `uv sync` |
| `Gemfile` | `bundle install` |
| `flake.nix` | `nix develop` |
| `go.mod` | `go mod download` |
| `mix.exs` | `mix deps.get` |

## Handoff

Include the absolute path, stable change ID, exact `cd`, exact
`jj edit <change-id>`, scope boundaries, the inline-message rule, and the
status-after-mutation rule.

```text
Workspace: /absolute/path/to/.workspaces/myrepo-tests
Change ID: abcdefgh

cd /absolute/path/to/.workspaces/myrepo-tests
jj edit abcdefgh

Rules:
- Always use -m for messages.
- Run jj st after every mutation.
- Do not modify files outside the assigned scope.
```

## Inspect

Use the compact log from [`TEMPLATES.md`](TEMPLATES.md) with a different
revset:

- All tips: `-r 'working_copies()'`
- One workspace: `-r '<workspace>@'`

Default `jj workspace list` now shows roots; the compact template keeps them.
Syntax: [`QUERY_LANGUAGES.md`](QUERY_LANGUAGES.md).

## Integrate

When a result is ready, ask the user rather than choosing silently: rebase into
the default workspace, explicit merge, or bookmark/PR.

Rebase ordinary commits:

```bash
jj rebase -s <workspace-change-id> -d @
jj workspace forget <workspace-name>
rm -rf "$WORKSPACE_PATH"
```

Visible merge, when the lines are independently meaningful:

```bash
jj new <change-a> <change-b> -m "Combine parallel work"
```

Human review:

```bash
jj bookmark create my-feature -r <workspace-change-id>
jj git push -b my-feature
```

Solo parallel work usually means rebase; required review means a PR; two
meaningful lines mean a merge. Shipping a bookmark after rebase follows
[`PUSH.md`](PUSH.md).

## Cleanup and stale state

```bash
jj workspace list
jj workspace forget <workspace-name>
rm -rf "$WORKSPACE_PATH"
```

Forget first; it does not delete files.

If the base was rewritten elsewhere and the workspace is stale:

```bash
jj workspace update-stale
jj st
```

Use this before manual repair. If the old operation is unavailable, jj may
create a recovery commit from current files rather than discard them.

## Avoid collisions

- Generated or build outputs: ignore them or use separate paths.
- Shared config: give it one owner or serialize.
- Lockfile and dependencies: one task owns them.
- Same source files: redesign the boundary or serialize.

Required: absolute handoff, ignore check, descriptive name, bootstrap,
integration question, forget before delete, and update-stale first.
