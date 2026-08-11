# push

push only after explicit user request.

before push: correct bookmark target? commits atomic/refined? no conflicts? bookmark does not auto-advance.

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

multiple/named remotes, tracking, fork/upstream config? [`REMOTES.md`](REMOTES.md).
