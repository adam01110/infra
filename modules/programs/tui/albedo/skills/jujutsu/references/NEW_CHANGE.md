# Start a change

Inspect `@` before the first edit. One described change per task does not mean
creating a new commit when the working copy is already empty.

```bash
jj --no-pager st
jj --no-pager log -r @ --no-graph -T 'empty ++ " " ++ description.first_line()'
```

- `true` and undescribed: reuse `@` with `jj desc -m "<summary>"`. Already
  describes this task: keep it. Describes other work or is an empty merge:
  `jj new -m "<summary>"`.
- `false`: preserve existing work with `jj new -m "<summary>"`.
- If the user explicitly says to amend, edit that change in place and describe
  it with inline `-m`.
- If the user specifies another base, follow [`NONLINEAR.md`](NONLINEAR.md).

Then edit files and run `jj st`. `@` is the working-copy commit, so edits land
there. There is no `jj add` and no staging, and no closing `jj commit` step is
needed.

Avoid:

- Editing before describing the task.
- Creating a child of an empty `@` just to start a task.
- Mixing unrelated work into a nonempty `@`.
- Automatically abandoning empty ancestors.
- Bare `jj desc`, which opens an editor; use inline `-m`.
- `jj new` at the end of a task, which leaves an empty undescribed `@` behind.

Keep the description to one logical change. If the change grows too big, split
it: [`REFINE_COMMIT.md`](REFINE_COMMIT.md). For unrelated work, see
[`NONLINEAR.md`](NONLINEAR.md).
