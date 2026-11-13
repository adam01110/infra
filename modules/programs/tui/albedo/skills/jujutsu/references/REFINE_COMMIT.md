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

Bare `jj split` opens an interactive editor, so agents always pass filesets and
a message: `jj split -m "First part" <paths>` moves those paths into the first
commit and leaves the rest in the second. For hunk-level splits, move changes
with `jj restore` and create separate commits manually.

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

`jj absorb -i` is interactive; humans may use `-i`, agents do not. Run `jj st`
after a mutation, and `jj undo` before manual repair if a successful mutation
gave an unexpected result and `jj op log -n 5` shows it is the latest op.
