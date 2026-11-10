---
name: jujutsu
description: >-
  Use at the start of any coding task in a repository containing a .jj
  directory, before the first file edit and before any jj or git command.
  Covers starting a described change, plus commits, branches, conflicts,
  workspaces, history, and push.
license: Apache-2.0
compatibility:
  Requires jj 0.44.0 or compatible and shell access to a repository.
metadata:
  author: johnstegeman
  version: "1.5"
  short-description: Perform safe version-control operations with Jujutsu
allowed-tools: Bash(jj *)
---

# jujutsu

Assumes jj 0.44.0. On another version, commands may differ; check the help.

## Required flow

Before each task, inspect the working copy and describe the task before editing.

```bash
jj root                      # an error means this is not a jj repo; skip this skill
jj st
jj log -r @ --no-graph -T 'empty ++ "\n"'
# true: reuse @
jj desc -m "Add login validation"
# false: instead create a new change
# jj new -m "Add login validation"
# edit files; the next jj command snapshots them
jj st
```

- If `@` is empty, reuse it with `jj desc -m "<summary>"`, even if already
  described. Do not create a child just because a new task starts.
- If `@` is nonempty, run `jj new -m "<summary>"` to keep existing work separate.
- Explicit user instructions about the change or base take precedence.

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

Run `jj root`. A returned path means a jj repo. On the no-repo error, or with no
`.jj/`, stop using this skill.

A jj repo may also contain `.git/`; jj still owns mutations.

## Mutation gate

Do not mutate with git in a jj repo. Forbidden: `git commit`, `git add`,
`git stash`, `git reset`, `git checkout <branch>`, `git switch`, `git rebase`,
`git merge`, `git cherry-pick`, `git push`, `git pull`.

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

Avoid bare `jj desc`, `jj squash` into a described commit, `jj split`,
interactive flags, and bare `jj resolve`, because they can prompt and hang.

Run `jj st` after a mutation such as squash, abandon, rebase, or restore. If an
operation fails or surprises you, run `jj undo` first.

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
jj log
jj log -p
jj show <change-id>
jj diff
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
jj bookmark list
jj bookmark delete my-feature
```

Push only when the user explicitly asks; see
[`references/PUSH.md`](references/PUSH.md) and
[`references/REMOTES.md`](references/REMOTES.md).

## Workspaces

When parallel agents touch the same repo, isolate their working copies:

```bash
jj workspace add .workspaces/<repo>-<purpose>
jj workspace list
jj workspace forget <name>
```

Workspaces share the store and op log but have separate `@`. The `.gitignore`
check, directory priority, bootstrap, handoff, integration choice, and stale
recovery are all required:
[`references/WORKSPACES.md`](references/WORKSPACES.md).

## Co-located git

For an existing git project, prefer co-location:

```bash
jj git clone <url> --colocate
jj git init --colocate
```

Tags are native in jj 0.44: create them with `jj tag set`, track them with
`jj tag track`, and push them with `jj git push -t`. See
[`references/PUSH.md`](references/PUSH.md). Co-location safety:
[`references/COLOCATED.md`](references/COLOCATED.md).

## Conflicts

A rebase or squash can succeed with a conflicted commit. The conflict persists,
and push rejects it by default. Do not bypass this with
`jj git push --allow-conflicts`.

```bash
jj st
jj resolve --list
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
jj op log
jj op restore <op-id>
jj evolog -r <change>
```

When something goes wrong, run `jj undo` first rather than reversing by hand.
For an older state, inspect ops compactly first; request patches only after
narrowing. Scenarios: [`references/RECOVERY.md`](references/RECOVERY.md).

## Provenance

Fork: [danverbraganza](https://skills.sh/danverbraganza/jujutsu-skill/jujutsu).
Mutation gate: [knoopx](https://skills.sh/knoopx/pi/jujutsu). Agent workspaces:
[onevcat](https://skills.sh/onevcat/skills/onevcat-jj). Local workspace path:
[edmundmiller](https://lobehub.com/skills/edmundmiller-dotfiles-using-jj-workspaces).
Recovery framing: [trevors](https://skills.sh/trevors/dot-claude/jj-workflow).
Queries, nonlinear work, handoff:
[joshuadavidthomas](https://github.com/joshuadavidthomas/agent-skills/tree/main/jj).
