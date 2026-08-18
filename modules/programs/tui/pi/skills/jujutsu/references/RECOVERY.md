# recovery and operation log

op log records every repo mutation. bad squash, abandon, rebase, restore? work recoverable.

## primitives

first choice:

```bash
jj undo
```

reverses latest operation atomically, including abandon, squash, rebase,
restore, describe. never manually unwind first.

need older operation:

```bash
jj op log
jj op log -n 20
jj op log -p
jj op restore <op-id>
```

start compact command from [`TEMPLATES.md`](TEMPLATES.md). narrow op IDs; only
then `-p`. `op restore` restores whole repo state and itself creates recoverable
op. wrong restore? `jj undo`.

single change evolution:

```bash
jj evolog
jj evolog -r <change-id>
jj evolog -p
```

compact first; patch only after narrowing. useful for pre-rewrite commit version.

## scenarios

wrong abandon just happened? `jj undo`. later? find preceding op,
`jj op restore <op-id>`.

squash into wrong parent or bad rebase? `jj undo`. more work followed? inspect op
log and restore earlier op; understand later ops no longer active before
choosing.

lost work after sequence? `jj op log -p`; find last state containing work;
restore it.

need old file version:

```bash
jj evolog -r <change-id> -p
jj restore --from <commit-id-from-evolog> <path>
```

no stash/pop needed. each state already commit/op-log history. op log retained
long enough for ordinary recovery; do not assume loss.

| need | command |
|---|---|
| reverse latest op | `jj undo` |
| list ops | `jj op log` |
| op diffs | `jj op log -p` |
| restore repo state | `jj op restore <op-id>` |
| change history | `jj evolog -r <change-id>` |
| recover file | `jj restore --from <commit-id> <path>` |
