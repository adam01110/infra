# Recovery and operation log

The op log records every repo mutation, so work is recoverable after a bad
squash, abandon, rebase, or restore.

## Primitives

First choice:

```bash
jj undo
```

It atomically reverses the latest operation, including abandon, squash, rebase,
restore, and describe. Use it before unwinding by hand, but only after
`jj op log -n 5` shows the latest operation is the one you want to reverse: the
op log is shared by every workspace and agent, and a failed command records no
operation, so undo after a failure reverses someone's earlier work.

For an older operation:

```bash
jj op log
jj op log -n 20
jj op log -p
jj op restore <op-id>
```

Start with the compact command from [`TEMPLATES.md`](TEMPLATES.md); narrow op
IDs before `-p`. `op restore` restores the whole repo state and itself creates
a recoverable op; undo a wrong restore with `jj undo`.

Evolution of a single change:

```bash
jj evolog
jj evolog -r <change-id>
jj evolog -p
```

Start compact; add the patch only after narrowing. Useful for a commit's
pre-rewrite version.

## Scenarios

- Wrong abandon just happened: `jj undo`. Noticed later: find the preceding op
  and run `jj op restore <op-id>`.
- Squash into the wrong parent, or a bad rebase: `jj undo`. If more work
  followed, inspect the op log and restore an earlier op, knowing which later
  ops become inactive.
- Work lost after a sequence: run `jj op log -p`, find the last state with the
  work, and restore it.

Old file version:

```bash
jj evolog -r <change-id> -p
jj restore --from <commit-id-from-evolog> <path>
```

No stash/pop is needed; every state is already in commit or op-log history.
The op log is kept long enough for ordinary recovery, so do not assume loss.

| need | command |
|---|---|
| reverse latest op | `jj undo` |
| list ops | `jj op log` |
| op diffs | `jj op log -p` |
| restore repo state | `jj op restore <op-id>` |
| change history | `jj evolog -r <change-id>` |
| recover file | `jj restore --from <commit-id> <path>` |
