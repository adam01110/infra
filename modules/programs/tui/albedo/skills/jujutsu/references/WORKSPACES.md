# parallel workspaces

assume jj 0.44.0. multiple agents need same repo? separate `@` through
`jj workspace`; store and op log shared.

## directory decision

priority is exact:

1. `.workspaces/`
2. `workspaces/`
3. repo instructions such as `AGENTS.md` or `CLAUDE.md`
4. ask user

no blanket sibling-directory rule.

before create, prevent workspace metadata entering git:

```bash
grep -E '^\.?workspaces/?$' .gitignore 2>/dev/null
```

missing entry? add chosen directory ignore through normal describe-first
workflow from [`NEW_CHANGE.md`](NEW_CHANGE.md) before workspace creation. never
skip.

name descriptive:

```bash
REPO_NAME=$(basename "$(jj workspace root)")
WORKSPACE_PATH=".workspaces/${REPO_NAME}-<purpose>"
jj workspace add "$WORKSPACE_PATH"
cd "$WORKSPACE_PATH"
```

avoid `tmp`, `wip`, `new`. workspace gets own working-copy commit and
`<workspace-name>@` marker; snapshots affect only its `@`.

## bootstrap

handoff only after required environment setup:

| marker | command |
|---|---|
| `package.json` | `npm install` |
| `Cargo.toml` | `cargo build` |
| `pyproject.toml` | `uv sync` |
| `Gemfile` | `bundle install` |
| `flake.nix` | `nix develop` |
| `go.mod` | `go mod download` |
| `mix.exs` | `mix deps.get` |

## handoff

always provide absolute path, stable change ID, exact `cd`, exact
`jj edit <change-id>`, scope boundaries, inline-message rule,
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

## inspect

use compact log from [`TEMPLATES.md`](TEMPLATES.md), changing revset:

- all tips: `-r 'working_copies()'`
- one: `-r '<workspace>@'`

default `jj workspace list` now shows roots. compact template also keeps root.
syntax: [`QUERY_LANGUAGES.md`](QUERY_LANGUAGES.md).

## integrate

result ready? do not silently pick strategy. ask user: rebase into default
workspace, explicit merge, or bookmark/PR.

rebase ordinary commits:

```bash
jj rebase -s <workspace-change-id> -d @
jj workspace forget <workspace-name>
rm -rf "$WORKSPACE_PATH"
```

visible merge when lines independently meaningful:

```bash
jj new <change-a> <change-b> -m "Combine parallel work"
```

human review:

```bash
jj bookmark create my-feature -r <workspace-change-id>
jj git push -b my-feature
```

solo parallel work usually rebase. review required means PR. meaningful dual
lines means merge. bookmark shipping after rebase follows [`PUSH.md`](PUSH.md).

## cleanup and stale state

```bash
jj workspace list
jj workspace forget <workspace-name>
rm -rf "$WORKSPACE_PATH"
```

forget first; it does not delete files.

base rewritten elsewhere and workspace stale?

```bash
jj workspace update-stale
jj st
```

use before manual repair. old operation unavailable? jj may create recovery
commit from current files rather than discard.

## avoid collisions

- generated/build outputs: ignore or separate paths.
- shared config: one owner or serialize.
- lockfile/dependencies: one task owns.
- same source files: redesign boundary or serialize.

absolute handoff, ignore check, descriptive name, bootstrap, integration
question, forget-before-delete, and update-stale-first are mandatory.
