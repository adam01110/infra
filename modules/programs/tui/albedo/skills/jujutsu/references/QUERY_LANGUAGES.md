# Query languages

Assumes jj 0.44.0. Use queries to narrow revisions, paths, and output instead of
the verbose defaults.

## Revsets

- `@`: current working-copy change.
- `@-`: parent.
- `trunk()`: configured mainline; do not guess `main`/`master`.
- `::@`: ancestors of `@`.
- `trunk()..@`: current work reachable off trunk.
- `working_copies()`: all workspace tips.
- `<workspace>@`: named workspace tip.
- `<change-id>`: stable ID.

```bash
jj --no-pager log -r 'trunk()..@'
jj --no-pager log -r 'working_copies()'
jj --no-pager log -r '<workspace>@'
```

Shell-quote any query containing punctuation or a function.

## Filesets

- `path` / `"path"`: cwd-relative `prefix-glob:` pattern.
- `cwd:"path"`: literal cwd-relative prefix.
- `file:"path"`: exact cwd-relative file.
- `glob:"pattern"`: cwd-relative glob.
- `root:"path"`: workspace-relative prefix.
- `~x`: except x.
- `x & y`: intersection.
- `x | y`: union.
- `x ~ y`: subtraction.

```bash
jj diff 'glob:"*.md"'
jj diff 'src ~ glob:"src/**/*.snap"'
jj diff 'file:"README.md"'
```

## Templates

Common pieces: `++`, `if(cond, a, b)`, `description.first_line()`,
`change_id.shortest(8)`, `bookmarks`, `current_working_copy`, `empty`, `conflict`.

<!-- rumdl-disable MD013 -->

```bash
jj --no-pager log --no-graph -n 5 -T 'change_id.shortest(8) ++ " " ++ if(description, description.first_line(), "(no description)") ++ "\n"'
```

<!-- rumdl-enable MD013 -->

Start with [`TEMPLATES.md`](TEMPLATES.md); write a new template only when the
need differs.

If parsing fails, check `jj <command> --help`, `jj help -k revsets`,
`jj help -k filesets`, or `jj help -k templates`.
