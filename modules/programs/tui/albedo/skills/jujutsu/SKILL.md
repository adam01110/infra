---
name: jujutsu
description: >-
  Use at the start of any task that edits files in a repository containing a
  .jj directory, before the first file edit, and before any mutating jj or git
  command.
  Covers starting a described change, plus commits, branches, conflicts,
  workspaces, history, and push.
license: Apache-2.0
compatibility: Requires jj and a jj repository.
metadata:
  author: johnstegeman, adapted by Adam0
  version: "1.5"
  short-description: Perform safe version-control operations with Jujutsu
---

# jujutsu

Command blocks list jj invocations; run each through `run("jj", ...)` in the
harness, which has no shell.

Commands and flags change between jj releases. If one fails or looks
unfamiliar, check `jj <command> --help` instead of guessing.

## Required flow

Before each task, inspect the working copy and describe the task before editing.

```bash
jj --no-pager st
jj --no-pager log -r @ --no-graph -T 'empty ++ " " ++ description.first_line()'
# "true" with no description: reuse @
jj desc -m "Add login validation"
# otherwise, per the rules below, create a new change
# jj new -m "Add login validation"
# edit files; the next jj command snapshots them
jj st
```

- If `@` is empty and undescribed, reuse it with `jj desc -m "<summary>"`. Do
  not create a child just because a new task starts.
- If `@` is empty but already describes this task, keep it. If it describes
  something else, or is an empty merge (`jj new a b`), leave it and run
  `jj new -m "<summary>"`.
- If `@` is nonempty, run `jj new -m "<summary>"` to keep existing work separate.
- Explicit user instructions about the change or base take precedence.
- A child session working in a checkout its parent owns leaves `@` alone: no
  `jj desc`, `jj new`, or other mutation unless its brief says so. The parent
  owns the change. A child in its own worktree follows the flow above.

Describe first, because edits made before that land in an old change or an
undescribed `@`.

At task end, leave `@` described. Do not close it with `jj new` or `git commit`.

Exceptions:

- If the user says to amend this change, run `jj desc -m "..."`, not `jj new`.
- Do not automatically abandon an empty ancestor; reuse `@` to avoid adding more.
- If the work belongs beside `trunk()`, see
  [`references/NONLINEAR.md`](references/NONLINEAR.md).

More detail: [`references/NEW_CHANGE.md`](references/NEW_CHANGE.md).

- Compact inspection: [`references/TEMPLATES.md`](references/TEMPLATES.md).
- Query syntax: [`references/QUERY_LANGUAGES.md`](references/QUERY_LANGUAGES.md).
- Unrelated or sibling work: [`references/NONLINEAR.md`](references/NONLINEAR.md).
- Surprising behavior: [`references/GOTCHAS.md`](references/GOTCHAS.md).

## Detect

This skill loads after a `.jj/` directory was found in the current or a parent
directory. A jj repo may also contain `.git/`; jj still owns mutations.

## Mutation gate

Do not mutate with git in a jj repo. Forbidden: `git commit`, `git add`,
`git stash`, `git reset`, `git checkout <branch>`, `git switch`, `git rebase`,
`git merge`, `git cherry-pick`, `git fetch`, `git push`, `git pull`, `git tag`.

Read-only commands are safe: `git log`, `git show`, `git diff`, `git blame`,
`git grep`, `git status`. Prefer the jj equivalents.

Use `jj git push`, `jj git fetch`, `jj edit <change>`, `jj rebase`, and
`jj new <a> <b>`. Co-located details:
[`references/COLOCATED.md`](references/COLOCATED.md).

## Agent rules

Run only noninteractive commands. Pass `-m` inline to any command that takes a
message:

```bash
jj desc -m "Add login validation"
jj squash --into @- -m "Combine login validation"
```

Avoid any message-taking command without `-m` (bare `jj desc`, `jj squash`
into a described commit without `-m`), bare `jj split` (pass `-m` and
filesets: `jj split -m "..." <paths>`), interactive flags, and bare
`jj resolve`, because they open an editor or prompt and hang.

Run `jj st` after a mutation such as squash, abandon, rebase, or restore.

A failed jj command records no operation, so read its error instead of
undoing. If a mutation succeeded but did the wrong thing, confirm with
`jj op log -n 5` that the latest operation is yours, then `jj undo`. The op log
is shared by every workspace and agent on the repo.

## Model

The working directory is the commit `@`, snapshotted when jj commands run.
There is no staging, no `jj add`, and no closing `jj commit` step. Commits are
mutable.

A change ID stays stable across rewrites; the commit ID hash changes, so refer
to changes by change ID.

One commit holds one logical change. Keep unrelated work separate.

## Inspect narrowly

Default to the compact commands in
[`references/TEMPLATES.md`](references/TEMPLATES.md), all with `jj --no-pager`.
Narrow the revset or fileset before requesting large patches.

```bash
jj --no-pager log
jj --no-pager log -p
jj --no-pager show <change-id>
jj --no-pager diff
```

Query grammar: [`references/QUERY_LANGUAGES.md`](references/QUERY_LANGUAGES.md).

Move between changes:

```bash
jj new -m "Describe next change"
jj edit <change-id>
jj prev -e
jj next -e
```

## Refine

For squash, restore, absorb, abandon, and alternatives to split, see
[`references/REFINE_COMMIT.md`](references/REFINE_COMMIT.md). Review with
`jj show @` or `jj diff`, keep the change atomic, and remove or move unrelated
edits. Then run `jj st`.

Bookmarks are branches, but they do not auto-advance:

```bash
jj bookmark create my-feature -r@
jj bookmark move my-feature --to <change-id>
jj --no-pager bookmark list
jj bookmark delete my-feature
```

Push only when the user explicitly asks; see
[`references/PUSH.md`](references/PUSH.md) and
[`references/REMOTES.md`](references/REMOTES.md).

## Workspaces

When parallel agents touch the same repo, give each its own working copy with
the harness: `wt = await worktrees.create(name="<purpose>")`, then
`agents.self.spawn(..., worktree=wt)`. For a jj repo this is a jj workspace:
shared store and op log, separate `@`. Integration and cleanup:
[`references/WORKSPACES.md`](references/WORKSPACES.md).

## Co-located git

`jj git init` and `jj git clone` colocate with git by default, unless
`git.colocate = false` is set; do not add `--no-colocate` without a reason.

Tags are native: create them with `jj tag set`, track them with
`jj tag track`, and push them with `jj git push -t`. See
[`references/PUSH.md`](references/PUSH.md). Co-location safety:
[`references/COLOCATED.md`](references/COLOCATED.md).

## Conflicts

A rebase or squash can succeed with a conflicted commit. The conflict persists,
and push rejects it by default. Do not bypass this with
`jj git push --allow-conflicts`.

```bash
jj --no-pager st
jj --no-pager resolve --list
jj resolve --tool :ours
jj resolve --tool :theirs
```

Do not run bare `jj resolve`. Choose a side with an explicit tool, or edit the
markers directly. Then check status, grep for markers, and run project checks.
If the same conflict repeats in descendants, resolve the first conflicted
ancestor. Full playbook: [`references/CONFLICTS.md`](references/CONFLICTS.md).

## Recovery

The op log records every mutation, so work is recoverable.

```bash
jj undo
jj --no-pager op log
jj op restore <op-id>
jj --no-pager evolog -r <change>
```

When a mutation went wrong, prefer the op log over reversing by hand, after
checking that the operation you undo is yours (see Agent rules). For an older
state, inspect ops compactly first; request patches only after
narrowing. Scenarios: [`references/RECOVERY.md`](references/RECOVERY.md).

## Provenance

Fork: [danverbraganza](https://skills.sh/danverbraganza/jujutsu-skill/jujutsu).
Mutation gate: [knoopx](https://skills.sh/knoopx/pi/jujutsu). Agent workspaces:
[onevcat](https://skills.sh/onevcat/skills/onevcat-jj). Local workspace path:
[edmundmiller](https://lobehub.com/skills/edmundmiller-dotfiles-using-jj-workspaces).
Recovery framing: [trevors](https://skills.sh/trevors/dot-claude/jj-workflow).
Queries, nonlinear work, handoff:
[joshuadavidthomas](https://github.com/joshuadavidthomas/agent-skills/tree/main/jj).
