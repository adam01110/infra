# start change

inspect `@` before the first edit. one described change per task does not mean
creating a new commit when the working copy is already empty.

```bash
jj root
jj st
jj log -r @ --no-graph -T 'empty ++ "\n"'
```

- `true`: reuse `@` with `jj desc -m "<summary>"`, even if already described.
- `false`: preserve existing work with `jj new -m "<summary>"`.
- user explicitly says amend? edit that change in place; describe with inline `-m`.
- user specifies another base? follow [`NONLINEAR.md`](NONLINEAR.md).

then edit files and run `jj st`. `@` is the working-copy commit; edits land
there. no `jj add`, no `jj commit`, no staging.

avoid:

- editing before describing the task.
- creating a child of empty `@` just to start a task.
- mixing unrelated work into nonempty `@`.
- automatically abandoning empty ancestors.
- bare `jj desc`, which opens an editor; always use inline `-m`.
- `jj new` at the end of a task, leaving empty undescribed `@` behind.

keep the description to one logical change. too big? split:
[`REFINE_COMMIT.md`](REFINE_COMMIT.md). unrelated work?
[`NONLINEAR.md`](NONLINEAR.md).
