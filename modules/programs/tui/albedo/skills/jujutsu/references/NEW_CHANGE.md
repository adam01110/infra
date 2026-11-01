# start change

every task: `jj new -m "<summary>"` before first edit. one change per task,
always described.

```bash
jj root
jj new -m "Add login validation"
# edit. next jj command snapshot
jj st
```

`@` is working copy commit. edit land there. no `jj add`, no `jj commit`, no
staging.

user say amend? `jj desc -m "..."`, edit in place. stray `@-`
`(empty) (no description set)`? `jj abandon @-`. nothing lost.

avoid demon:

- code before description.
- reuse of undescribed `@`.
- bare `jj desc`. editor hang. always inline `-m`.
- `jj commit` thinking.
- `jj new` at end of task, leave empty undescribed `@` behind.

description one logical change. too big? split,
[`REFINE_COMMIT.md`](REFINE_COMMIT.md). unrelated work?
[`NONLINEAR.md`](NONLINEAR.md).
