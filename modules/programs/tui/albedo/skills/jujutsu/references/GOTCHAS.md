# Gotchas

- `@` is a commit, not staging. `jj new` starts the next change; it does not
  finish the current one.
- Most commands, including `jj st` and `jj log`, may snapshot the filesystem.
  For an intentionally stale view, use `--ignore-working-copy`.
- Change IDs are stable across rewrites; commit IDs change. Hand off change IDs.
- A failed command records nothing; do not `jj undo` after it. After a bad but
  successful rebase, squash, or abandon, check `jj op log -n 5` that the latest
  op is yours, then `jj undo`. See [`RECOVERY.md`](RECOVERY.md).
- If default output is too large, use the compact `jj --no-pager` commands from
  [`TEMPLATES.md`](TEMPLATES.md).
- Co-located repos still forbid git mutation. Only `git log`, `show`, `diff`,
  `blame`, `grep`, `status` are safe.
- `jj workspace forget` only unregisters; the files remain.
- For a stale parallel workspace, run `jj workspace update-stale`, then `jj st`.
- Bare `jj resolve` is interactive. Use `--tool :ours`, `--tool :theirs`, or
  edit the markers.
- `jj git fetch` fetches and auto-tracks matching tags. Set
  `remotes.<name>.fetch-tags = '~*'` to disable it.
- `jj git push --allow-conflicts` can push conflicts. Agents do not.
- Narrow with a revset or fileset before `jj log -p` or a full show.

If surprised, check [`NEW_CHANGE.md`](NEW_CHANGE.md),
[`TEMPLATES.md`](TEMPLATES.md), [`WORKSPACES.md`](WORKSPACES.md), and
[`RECOVERY.md`](RECOVERY.md). Do not invent a git-style workaround.
