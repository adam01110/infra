# Refine a commit

## Squash

Moves changes from source to destination; by default `@` to its parent.

```bash
jj squash
jj squash --into <change-id>
jj squash -t <change-id>
jj squash -r <change-id>
jj squash --from <source-id> --into <destination-id>
jj squash path/to/file.txt
jj squash --into <change-id> src/auth/
```

If both descriptions are nonempty, the bare command opens an editor to combine
them, so pass `-m`:

```bash
jj squash --into <change-id> -m "Combine authentication changes"
```

An emptied source is abandoned by default; `--keep-emptied` keeps a placeholder.

Do not use `-i`/`--interactive`; the TUI hangs.

## Split

`jj split` is interactive, so agents do not use it. Move selected changes with
`jj restore`, then create separate commits manually.

## Other tools

```bash
jj absorb                            # distribute lines to prior owning commits
jj absorb -i                         # interactive; agents avoid it
jj abandon <change-id>               # remove; descendants rebase to parent
jj undo                              # reverse last operation
jj restore                           # working copy from parent
jj restore path/to/file.txt
jj restore --from <change-id> path/to/file.txt
```

0.44 adds interactive absorb; humans may use `-i`, agents do not. Run `jj st`
after a mutation, and `jj undo` before manual repair if the result is
unexpected.
