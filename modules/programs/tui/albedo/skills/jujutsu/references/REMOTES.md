# Remotes

For a single-remote push, see [`PUSH.md`](PUSH.md). Multiple remotes need an
explicit target and tracking decisions. Official guide:
<https://docs.jj-vcs.dev/latest/guides/multiple-remotes/>.

```bash
jj git remote list
jj git remote add upstream <url>
jj git remote rename origin fork
jj git remote set-url origin <new-url>
jj git remote remove old-name
```

Without `--remote`, push selects the `git.push` config, then `origin` when there
are several remotes, then the sole remote. One command cannot push to several
remotes; run it once per remote.

```bash
jj bookmark move my-feature --to @
jj git push -b my-feature --remote fork
jj git push -b my-feature --remote upstream
```

Set a default:

```bash
jj config set --repo git.push fork
jj config set --user git.push origin
```

Remote bookmarks and tags appear as `<name>@<remote>`. If a symbol is ambiguous,
the tag wins. To make a local bookmark follow a remote one:

```bash
jj bookmark track main@upstream
jj bookmark track 'glob:release/*@upstream'
jj git push --tracked --remote upstream
```

Fetch:

```bash
jj git fetch --remote upstream
jj git fetch --all-remotes
```

0.44 fetches tags and auto-tracks same-name local tags. Disable this per remote
only when intended:

```bash
jj config set --repo remotes.upstream.fetch-tags '~*'
```

If a push is rejected because the remote moved, fetch the target, resolve the
bookmark conflict or rebase, and retry. The refusal works like lease protection.

## Choose a topology

jj naming: `origin` is the writable push target; `upstream` is the canonical
source. Examples assume `main`.

### Contributing fork

Features go from the fork `origin` into canonical `upstream` through PRs. Fetch
both, push to the fork, and let upstream main define the immutable trunk.

<!-- rumdl-disable MD013 -->

```bash
jj config set --repo git.fetch '["upstream", "origin"]'
jj config set --repo git.push origin
jj bookmark track main
jj config set --repo 'revset-aliases."trunk()"' main@upstream
```

<!-- rumdl-enable MD013 -->

Tracking `main` tracks both matching remote bookmarks. Fetch updates local main;
push keeps the fork's main in sync. The trunk boundary prevents rewriting
canonical commits.

### Independent divergent repo

`origin` owns the long-lived line; `upstream` is only an occasional source.
Track only origin main, and let origin define trunk.

<!-- rumdl-disable MD013 -->

```bash
jj config set --repo git.fetch '["origin"]'
# optional every-fetch visibility:
# jj config set --repo git.fetch '["upstream", "origin"]'
jj config set --repo git.push origin
jj bookmark track main --remote=origin
jj bookmark untrack main --remote=upstream
jj config set --repo 'revset-aliases."trunk()"' main@origin
```

<!-- rumdl-enable MD013 -->

Upstream stays separate, and integration stays explicit.

Choosing: if work is contributed back and upstream fetches should move local
main, use the fork setup. If there is no contribution, origin diverges on
purpose, and upstream is integrated manually, use the independent setup. If it
is unclear, ask before changing config.
