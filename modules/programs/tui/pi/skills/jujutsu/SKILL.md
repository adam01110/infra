---
name: jujutsu
description: Use for every version-control operation. In a .jj repo, all mutations must use jj; read-only git log/diff/show/blame/grep/status remain safe. Covers describe-first atomic changes, compact inspection, conflicts, workspaces, and operation-log recovery.
allowed-tools: Bash(jj *)
license: Apache-2.0
metadata:
  author: johnstegeman
  version: "1.3"
---

# jujutsu

jj version assumed: 0.41.0. version differs? command may differ; inspect help.

need compact inspection? [`references/TEMPLATES.md`](references/TEMPLATES.md). query syntax? [`references/QUERY_LANGUAGES.md`](references/QUERY_LANGUAGES.md). unrelated/sibling work? [`references/NONLINEAR.md`](references/NONLINEAR.md). surprise? [`references/GOTCHAS.md`](references/GOTCHAS.md).

## detect

run `jj root`. path returned? jj repo. exact no-repo error or no `.jj/`? stop using skill.

jj repo may also have `.git/`. still jj owns mutations.

## mutation gate

never mutate with git in jj repo. forbidden: `git commit`, `git add`, `git stash`, `git reset`, `git checkout <branch>`, `git switch`, `git rebase`, `git merge`, `git cherry-pick`, `git push`, `git pull`.

read-only safe: `git log`, `git show`, `git diff`, `git blame`, `git grep`, `git status`. prefer jj equivalents.

use `jj git push`, `jj git fetch`, `jj edit <change>`, `jj rebase`, `jj new <a> <b>`. co-located details: [`references/COLOCATED.md`](references/COLOCATED.md).

## agent rules

noninteractive only. message-taking command? always inline `-m`:

```bash
jj desc -m "Add login validation"
jj squash --into @- -m "Combine login validation"
```

bare `jj desc`, described-commit `jj squash`, `jj split`, interactive flags, bare `jj resolve` can prompt/hang. avoid.

mutation such as squash, abandon, rebase, restore? run `jj st` after. operation failed or surprising? `jj undo` first.

## model

working directory is commit `@`. jj snapshots filesystem on commands. no staging. no `jj add`; no closing `jj commit` step. commits mutable.

change ID remains stable across rewrite; commit ID hash changes. command reference? prefer change ID.

one commit = one logical change. unrelated work stays separate.

## start change: describe before edit

```bash
jj st
```

`@` empty? reuse. `@` has work to preserve? `jj new` first. then:

```bash
jj desc -m "Add login validation"
# edit files
jj st
```

never run `jj new` at task end. next task decides reuse/new. full branch logic: [`references/NEW_CHANGE.md`](references/NEW_CHANGE.md). work belongs on `trunk()` sibling? [`references/NONLINEAR.md`](references/NONLINEAR.md).

## inspect narrowly

agent inspection defaults to compact commands in [`references/TEMPLATES.md`](references/TEMPLATES.md), all with `jj --no-pager`. widen revset/fileset before requesting large patches.

```bash
jj log
jj log -p
jj show <change-id>
jj diff
```

need query grammar? [`references/QUERY_LANGUAGES.md`](references/QUERY_LANGUAGES.md).

move:

```bash
jj new
jj new && jj desc -m "Describe next change"
jj edit <change-id>
jj prev -e
jj next -e
```

## refine

squash, restore, absorb, abandon, split alternative? [`references/REFINE_COMMIT.md`](references/REFINE_COMMIT.md). review `jj show @` or `jj diff`; ensure atomic; remove unrelated edits or move them correctly. then `jj st`.

bookmarks are branches but do not auto-advance:

```bash
jj bookmark create my-feature -r@
jj bookmark move my-feature --to <change-id>
jj bookmark list
jj bookmark delete my-feature
```

push only when explicitly requested; see [`references/PUSH.md`](references/PUSH.md) and [`references/REMOTES.md`](references/REMOTES.md).

## workspaces

parallel agents touching same repo? isolate working copies:

```bash
jj workspace add .workspaces/<repo>-<purpose>
jj workspace list
jj workspace forget <name>
```

shared store/op log, separate `@`. `.gitignore` gate, directory priority, bootstrap, handoff, integration choice, stale recovery all mandatory: [`references/WORKSPACES.md`](references/WORKSPACES.md).

## co-located git

existing git project? prefer co-location:

```bash
jj git clone <url> --colocate
jj git init --colocate
```

need tags? jj cannot yet create and push tags; carefully switch to git mode only when required. all co-location safety: [`references/COLOCATED.md`](references/COLOCATED.md).

## conflicts

rebase/squash can succeed with conflicted commit. conflict persists; push blocked until resolved.

```bash
jj st
jj resolve --list
jj resolve --tool :ours
jj resolve --tool :theirs
```

bare `jj resolve`? never in agent. choose side with explicit tool or edit markers directly. then status, marker grep, project checks. repeated descendant conflict? resolve first conflicted ancestor. full playbook: [`references/CONFLICTS.md`](references/CONFLICTS.md).

## recovery

op log records mutations. work recoverable.

```bash
jj undo
jj op log
jj op restore <op-id>
jj evolog -r <change>
```

something wrong? `jj undo` first, not manual reversal. need older state? compact op inspection first; patches only after narrowing. scenarios: [`references/RECOVERY.md`](references/RECOVERY.md).

## provenance

fork: [danverbraganza](https://skills.sh/danverbraganza/jujutsu-skill/jujutsu). mutation gate: [knoopx](https://skills.sh/knoopx/pi/jujutsu). agent workspaces: [onevcat](https://skills.sh/onevcat/skills/onevcat-jj). local workspace path: [edmundmiller](https://lobehub.com/skills/edmundmiller-dotfiles-using-jj-workspaces). recovery framing: [trevors](https://skills.sh/trevors/dot-claude/jj-workflow). queries, nonlinear work, handoff: [joshuadavidthomas](https://github.com/joshuadavidthomas/agent-skills/tree/main/jj).
