# push

push only after explicit user request.

before push: correct bookmark/tag target? commits atomic/refined? no conflicts?
bookmark and tag do not auto-advance. `--allow-conflicts` exists in 0.44; never
use it.

existing bookmark:

```bash
jj bookmark move my-feature --to @
jj git push -b my-feature
```

no bookmark:

```bash
jj bookmark create my-feature
jj git push -b my-feature
```

specific example:

```bash
jj git push -b main
```

## tags

0.44 supports native tracked tags:

```bash
jj tag set v1.2.3 -r <change-id>
jj tag track v1.2.3@origin
jj git push -t v1.2.3 --remote origin
```

fetched tags auto-track by default. `jj git push --tracked` pushes tracked
bookmarks and tags. `jj git push --all` pushes all bookmarks and tags. prefer
`-b` or `-t`; broad push needs explicit user request.

multiple/named remotes, tracking, fork/upstream config?
[`REMOTES.md`](REMOTES.md).
