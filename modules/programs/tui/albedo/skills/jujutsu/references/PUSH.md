# Push

Push only after an explicit user request.

Before pushing, confirm the bookmark or tag targets the right change, the
commits are atomic and refined, and there are no conflicts. Bookmarks and tags
do not auto-advance. `--allow-conflicts` exists in 0.44; do not use it.

Existing bookmark:

```bash
jj bookmark move my-feature --to @
jj git push -b my-feature
```

No bookmark yet:

```bash
jj bookmark create my-feature
jj git push -b my-feature
```

Specific example:

```bash
jj git push -b main
```

## Tags

0.44 supports native tracked tags:

```bash
jj tag set v1.2.3 -r <change-id>
jj tag track v1.2.3@origin
jj git push -t v1.2.3 --remote origin
```

Fetched tags auto-track by default. `jj git push --tracked` pushes tracked
bookmarks and tags; `jj git push --all` pushes all bookmarks and tags. Prefer
`-b` or `-t`; a broad push needs an explicit user request.

Multiple or named remotes, tracking, and fork/upstream config:
[`REMOTES.md`](REMOTES.md).
