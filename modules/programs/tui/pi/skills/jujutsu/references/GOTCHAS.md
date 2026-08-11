# gotchas

assume jj 0.41.0.

- `@` is commit, not staging. `jj new` starts next change; does not finish current.
- most commands, including `jj st` and `jj log`, may snapshot filesystem. stale view intentionally needed? `--ignore-working-copy`.
- change ID stable across rewrites; commit ID changes. handoff uses change ID.
- bad rebase/squash/abandon? `jj undo` before manual repair. see [`RECOVERY.md`](RECOVERY.md).
- pager/default output too large? compact `jj --no-pager` commands from [`TEMPLATES.md`](TEMPLATES.md).
- co-located still forbids git mutation. only `git log`, `show`, `diff`, `blame`, `grep`, `status` safe.
- `jj workspace forget` unregisters only; files remain.
- stale parallel workspace? `jj workspace update-stale`, then `jj st`.
- bare `jj resolve` interactive. use `--tool :ours`, `--tool :theirs`, or edit markers.
- inspection too broad? targeted revset/fileset before `jj log -p` or full show.

surprise remains? inspect [`NEW_CHANGE.md`](NEW_CHANGE.md), [`TEMPLATES.md`](TEMPLATES.md), [`WORKSPACES.md`](WORKSPACES.md), [`RECOVERY.md`](RECOVERY.md). never invent git-style workaround.
