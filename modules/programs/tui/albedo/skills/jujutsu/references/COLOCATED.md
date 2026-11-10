# Co-located jj and git

A co-located root has both `.jj/` and `.git/`. jj owns local state; git
compatibility serves GitHub, CI, hooks, IDEs, and `gh`. Strongly prefer this
shape for existing git projects.

```bash
jj git init --colocate
jj git clone <url> --colocate
cd existing-git-repo
jj git init --colocate
```

With existing git history, always pass `--colocate`; otherwise a separate store
appears under `.jj/repo/store/git`.

## Mutation rule

Use git only to inspect:

| command | decision |
|---|---|
| `git log`, `git show`, `git diff`, `git blame`, `git grep`, `git status` | safe read-only; jj equivalent preferred |
| `git commit`, `git add`, `git stash`, `git reset` | forbidden |
| `git checkout <branch>`, `git switch` | forbidden; `jj edit` |
| `git rebase`, `git merge`, `git cherry-pick` | forbidden; `jj rebase`, `jj new <a> <b>`, `jj duplicate` |
| `git fetch` | use `jj git fetch` |
| `git pull` | forbidden; `jj git fetch` then `jj rebase` |
| `git push` | forbidden; `jj git push -b <bookmark>` |
| `git tag` | forbidden; `jj tag set`, `jj tag delete` |

jj snapshots the working copy, so a git mutation it does not see breaks its
state and op-log model.

## Forced git-only operation

If an external tool truly requires a git mutation, as a last resort:

```bash
jj st
# resolve and finish pending jj state
git <something>
jj st
jj edit <change-id>
```

A safer jj equivalent almost always exists.

## Surprises

- git reports uncommitted changes: that is its view of the jj working-copy
  commit. Trust `jj st`.
- Detached `HEAD`: jj manages it. Use `jj edit`, not `git checkout`.
- `.gitignore` is respected automatically. Use `.jjignore` only for jj-only
  patterns.
- Fetched git branches become bookmarks, which do not auto-advance.

Push:

```bash
jj bookmark move main --to @
jj git push -b main
```

Full push rules: [`PUSH.md`](PUSH.md).

## Native tags in 0.44

No git mode is needed:

```bash
jj tag set v1.2.3 -r <change-id>
jj tag list
jj tag track v1.2.3@origin
jj git push -t v1.2.3 --remote origin
```

Fetch now gets tags like bookmarks and tracks matching local tags. To skip tags,
set `remotes.<name>.fetch-tags = '~*'`. `jj git push --all` pushes bookmarks and
tags; default to a narrow `-b` or `-t`.
