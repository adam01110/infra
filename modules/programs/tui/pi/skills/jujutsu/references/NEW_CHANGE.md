# start change

rule: describe first, edit, refine. `@` already commit.

```bash
jj st
```

`@` empty and description absent/discardable? reuse. `@` contains work to
preserve? run `jj new`; creates empty child.

then, before file edit:

```bash
jj desc -m "Add login validation"
# edit; next jj command snapshots
jj st
```

one description should name one logical change. inline `-m` mandatory for
agent; editor prompt hangs. no `jj add`, no `jj commit`.

done? leave `@` there. do not `jj new` to close. next task performs same status
decision.

need split/squash/absorb/abandon?
[`REFINE_COMMIT.md`](REFINE_COMMIT.md). unrelated sibling?
[`NONLINEAR.md`](NONLINEAR.md).

avoid:

- code before description.
- bare `jj desc`.
- `jj commit` mental model.
- end-of-task `jj new` leaving empty `@`.
