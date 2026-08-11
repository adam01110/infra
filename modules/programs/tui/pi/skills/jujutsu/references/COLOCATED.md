# co-located jj + git

co-located root has `.jj/` and `.git/`. jj owns local state; git compatibility supports GitHub, CI, hooks, IDE, `gh`. existing git project? strongly prefer this shape.

```bash
jj git init --colocate
jj git clone <url> --colocate
cd existing-git-repo
jj git init --colocate
```

existing git history? never omit `--colocate`; otherwise separate store appears under `.jj/repo/store/git`.

## mutation rule

git may inspect only:

| command | decision |
|---|---|
| `git log`, `git show`, `git diff`, `git blame`, `git grep`, `git status` | safe read-only; jj equivalent preferred |
| `git commit`, `git add`, `git stash`, `git reset` | forbidden |
| `git checkout <branch>`, `git switch` | forbidden; `jj edit` |
| `git rebase`, `git merge`, `git cherry-pick` | forbidden; `jj rebase`, `jj new <a> <b>`, `jj duplicate` |
| `git fetch` | use `jj git fetch` |
| `git pull` | forbidden; `jj git fetch` then `jj rebase` |
| `git push` | forbidden; `jj git push -b <bookmark>` |

why? jj snapshots working copy. hidden git mutation breaks jj's state/op-log model.

## forced git-only operation

external tool truly requires mutation? last resort:

```bash
jj st
# resolve and finish pending jj state
git <something>
jj st
jj edit <change-id>
```

almost always safer jj equivalent exists.

## surprises

- git says uncommitted? normal view of jj working-copy commit. trust `jj st`.
- detached `HEAD`? jj manages it. never `git checkout`; use `jj edit`.
- `.gitignore` automatically respected. `.jjignore` only for jj-only patterns.
- fetched git branches become bookmarks. bookmarks do not auto-advance.

push:

```bash
jj bookmark move main --to @
jj git push -b main
```

full push gate: [`PUSH.md`](PUSH.md).
