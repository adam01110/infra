# Nonlinear work

Put work unrelated to the current stack in a sibling from
`trunk()`, not a forced child.

A sibling fits when `@` is already a logical change, independent lines are
requested, alternatives get compared or merged, or a quick fix interrupts a
feature.

```bash
jj st
jj new 'trunk()' -m "Handle stale workspace recovery"
# edit
jj st
```

Use `trunk()`; do not guess `main`/`master`.

Use a child (`jj new`) when work depends on the current change, a stack is
requested, or it is an intended follow-up. Use a sibling
(`jj new 'trunk()' -m "..."`) when review, landing, or abandoning should be
independent or parallel agents need separate history.

If both lines should remain visible, merge explicitly:

```bash
jj new <left-change> <right-change> -m "Combine related work"
```

Rebase one onto the other, visible merge, or separate pushes: this choice is
consequential, so ask the user.

Do not pile unrelated work into `@` or use describe, edit, or `jj new` as a
close-and-repeat loop. Choose the base first and pass `-m` with it;
do not default to `jj new 'trunk()' --no-edit -m ...` here.

Starting a change: [`NEW_CHANGE.md`](NEW_CHANGE.md). Parallel copies:
[`WORKSPACES.md`](WORKSPACES.md).
