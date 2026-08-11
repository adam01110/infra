# refine commit

## squash

moves changes source -> destination. default `@` -> parent.

```bash
jj squash
jj squash --into <change-id>
jj squash -t <change-id>
jj squash -r <change-id>
jj squash --from <source-id> --into <destination-id>
jj squash path/to/file.txt
jj squash --into <change-id> src/auth/
```

both descriptions nonempty? bare command opens combine-description editor. agent must pass inline message:

```bash
jj squash --into <change-id> -m "Combine authentication changes"
```

source emptied? jj abandons by default. placeholder needed? `--keep-emptied`.

`-i`/`--interactive`? TUI hangs. avoid.

## split

`jj split` interactive; agent must not use. move selected changes with `jj restore`, then create separate commits manually.

## other tools

```bash
jj absorb                            # distribute lines to prior owning commits
jj abandon <change-id>               # remove; descendants rebase to parent
jj undo                              # reverse last operation
jj restore                           # working copy from parent
jj restore path/to/file.txt
jj restore --from <change-id> path/to/file.txt
```

mutation done? `jj st`. unexpected? `jj undo` before manual repair.
