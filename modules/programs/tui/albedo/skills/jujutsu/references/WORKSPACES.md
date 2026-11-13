# Parallel workspaces

When several agents need one repo, give each its own `@`. In a jj repo the
harness worktree is a jj workspace: the store and op log stay shared, `@` is
separate.

## Create

```python
wt = await worktrees.create(name="<purpose>")
child = await agents.self.spawn(task, name="<purpose>", worktree=wt)
```

Use a descriptive name, not `tmp`, `wip`, or `new`. Worktrees live under
`~/.albedo/wt/`, outside the repo, so no `.gitignore` change is needed. Run
`jj workspace add` by hand only when the user asks for a workspace at a
specific path.

## Setup

Set up only what the child's task and tests need, within the compute budget in
its brief. There is no blanket bootstrap: do not run `npm install`,
`cargo build`, or a dev shell just because a marker file exists. For Nix dev
shells, follow the `nix-cli` skill.

## Handoff

The brief includes the worktree path, the stable change ID the child owns,
scope boundaries, the inline `-m` rule, and the `jj st`-after-mutation rule. A
child in its own worktree describes its own `@` as in
[`NEW_CHANGE.md`](NEW_CHANGE.md).

## Inspect

Use the compact log from [`TEMPLATES.md`](TEMPLATES.md) with a different
revset:

- All tips: `-r 'working_copies()'`
- One workspace: `-r '<workspace>@'`

Syntax: [`QUERY_LANGUAGES.md`](QUERY_LANGUAGES.md).

## Integrate

When a result is ready, ask the user rather than choosing silently: rebase into
the default workspace, explicit merge, or bookmark/PR.

```bash
jj rebase -s <workspace-change-id> -o @
jj new <change-a> <change-b> -m "Combine parallel work"
jj bookmark create my-feature -r <workspace-change-id>
```

Solo parallel work usually means rebase; required review means a PR; two
meaningful lines mean a merge. Pushing follows [`PUSH.md`](PUSH.md).

## Cleanup and stale state

After integration, `await worktrees.remove(wt.id)`. Worktrees are never deleted
automatically, and closing the child keeps them.

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
