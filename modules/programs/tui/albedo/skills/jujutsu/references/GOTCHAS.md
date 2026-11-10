# Gotchas

Assumes jj 0.44.0.

- `@` is a commit, not staging. `jj new` starts the next change; it does not
  finish the current one.
- Most commands, including `jj st` and `jj log`, may snapshot the filesystem.
  For an intentionally stale view, use `--ignore-working-copy`.
- Change IDs are stable across rewrites; commit IDs change. Hand off change IDs.
- After a bad rebase, squash, or abandon, run `jj undo` before manual repair.
  See [`RECOVERY.md`](RECOVERY.md).
- If default output is too large, use the compact `jj --no-pager` commands from
  [`TEMPLATES.md`](TEMPLATES.md).
- Co-located repos still forbid git mutation. Only `git log`, `show`, `diff`,
  `blame`, `grep`, `status` are safe.
- `jj workspace forget` only unregisters; the files remain.
- For a stale parallel workspace, run `jj workspace update-stale`, then `jj st`.
- Bare `jj resolve` is interactive. Use `--tool :ours`, `--tool :theirs`, or
  edit the markers.
- In 0.44, `jj git fetch` fetches and auto-tracks matching tags. Set
  `remotes.<name>.fetch-tags = '~*'` to disable it.
- 0.44 can push conflicts with `--allow-conflicts`. Agents do not.
- Narrow with a revset or fileset before `jj log -p` or a full show.

If surprised, check [`NEW_CHANGE.md`](NEW_CHANGE.md),
[`TEMPLATES.md`](TEMPLATES.md), [`WORKSPACES.md`](WORKSPACES.md), and
[`RECOVERY.md`](RECOVERY.md). Do not invent a git-style workaround.
