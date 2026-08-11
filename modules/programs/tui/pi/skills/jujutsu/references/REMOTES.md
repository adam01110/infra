# remotes

single remote push? [`PUSH.md`](PUSH.md). multiple remotes need explicit target and tracking decisions. official guide: <https://docs.jj-vcs.dev/latest/guides/multiple-remotes/>.

```bash
jj git remote list
jj git remote add upstream <url>
jj git remote rename origin fork
jj git remote set-url origin <new-url>
jj git remote remove old-name
```

no `--remote` on push? selection order: `git.push` config, then `origin` when multiple, then sole remote. one command cannot push several remotes; call once each.

```bash
jj bookmark move my-feature --to @
jj git push -b my-feature --remote fork
jj git push -b my-feature --remote upstream
```

set default:

```bash
jj config set --repo git.push fork
jj config set --user git.push origin
```

remote bookmarks appear as `<name>@<remote>`. local should follow one?

```bash
jj bookmark track main@upstream
jj bookmark track 'glob:release/*@upstream'
jj git push --tracked --remote upstream
```

fetch:

```bash
jj git fetch --remote upstream
jj git fetch --all-remotes
```

push rejected because remote moved? fetch target, resolve bookmark conflict/rebase, retry. refusal acts like lease protection.

## choose topology

jj naming: `origin` writable push target; `upstream` canonical source. examples assume `main`.

### contributing fork

features go from fork `origin` into canonical `upstream` via PR. fetch both; push fork; upstream main defines immutable trunk.

```bash
jj config set --repo git.fetch '["upstream", "origin"]'
jj config set --repo git.push origin
jj bookmark track main
jj config set --repo 'revset-aliases."trunk()"' main@upstream
```

tracking `main` tracks both matching remote bookmarks. fetch updates local main; push keeps fork main synced. trunk boundary prevents rewrite of canonical commits.

### independent divergent repo

`origin` owns long-lived line. `upstream` only occasional source. track origin main only; origin defines trunk.

```bash
jj config set --repo git.fetch '["origin"]'
# optional every-fetch visibility:
# jj config set --repo git.fetch '["upstream", "origin"]'
jj config set --repo git.push origin
jj bookmark track main --remote=origin
jj bookmark untrack main --remote=upstream
jj config set --repo 'revset-aliases."trunk()"' main@origin
```

upstream remains separate and integration stays explicit.

which? contribute back and upstream fetch should move local main -> fork scenario. no contribution, origin intentionally diverges, upstream manually integrated -> independent scenario. unclear? ask before config mutation.
