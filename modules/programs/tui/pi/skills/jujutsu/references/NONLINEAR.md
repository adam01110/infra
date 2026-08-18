# nonlinear work

assume jj 0.44.0. new work unrelated to current stack? sibling from `trunk()`,
not forced child.

sibling fits when current `@` already logical change, independent lines
requested, alternatives compared/merged, or quick fix interrupts feature.

```bash
jj st
jj new trunk()
jj desc -m "Handle stale workspace recovery"
# edit
jj st
```

use `trunk()`, never guess `main`/`master`.

child `jj new` when work depends on current, stack requested, or intentional
follow-up. sibling `jj new trunk()` when review/land/abandon should be
independent or parallel agents need separate history.

both lines should remain visible? explicit merge:

```bash
jj new <left-change> <right-change> -m "Combine related work"
```

rebase one onto other, visible merge, or separate pushes? consequential choice;
ask user.

never pile unrelated work into `@`. never use describe/edit/`jj new` as
close-and-repeat loop. base first, then separate `jj desc -m`; do not default to
`jj new trunk() --no-edit -m ...` here.

change start: [`NEW_CHANGE.md`](NEW_CHANGE.md). parallel copies: [`WORKSPACES.md`](WORKSPACES.md).
