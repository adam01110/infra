# Conflicts

In jj, a conflict is commit data. A rebase or squash that produces a conflict
succeeds, and the commit stays marked as conflicted. Further rebases are
allowed. Push rejects conflicted history by default.
`jj git push --allow-conflicts` exists; agents do not use it.

## Inspect

```bash
jj st
jj resolve --list
jj resolve --list -r <change-id>
jj log
jj config get ui.conflict-marker-style
```

Styles: `diff` is the modern default, `snapshot` shows full sides and base, `git`
is legacy 3-way.

`diff`:

```text
<<<<<<< Conflict 1 of 1
%%%%%%% Changes from base to side #1
-base content here
+side 1 content here
+++++++ Contents of side #2
side 2 content here
>>>>>>> Conflict 1 of 1 ends
```

`snapshot`:

```text
<<<<<<< Conflict 1 of 1
+++++++ Contents of side #1
side 1 content here
%%%%%%% Contents of base
base content here
+++++++ Contents of side #2
side 2 content here
>>>>>>> Conflict 1 of 1 ends
```

Side #1 is ours/destination, usually the current line. Side #2 is
theirs/source, usually the incoming or rebased line. To resolve manually,
replace the whole marker block with the final content.

## Choose a path

Bare `jj resolve` launches an interactive merge tool, so agents do not run it.

1. Complex merge: edit the markers directly, then run `jj st`.
2. One side is wholly correct:

```bash
jj resolve --tool :ours
jj resolve --tool :theirs
jj resolve --tool :ours path/to/file.rs
```

3. Another revision is correct:

```bash
jj restore --from <change-id> path/to/file.txt
```

4. The change is not worth keeping:

```bash
jj abandon <change-id>
```

Descendants rebase, and their conflicts remain.

5. The same conflict repeats in descendants: resolve the earliest conflicted
   ancestor once.

```bash
jj log -r 'roots(conflicts())'
jj edit <ancestor-change-id>
# edit markers
jj st
jj edit <original-change-id>
```

jj propagates the fix. Record the original ID before moving, because `@-` may
not return you to the prior location.

## Verify

Status alone is not enough:

```python
await run("jj", "--no-pager", "resolve", "--list").text(check=False)
await files.find(r"^(<{7,}|>{7,}|%{7,}|\+{7,}|\\{7,})( |$)", ".")
# then run project tests and linters
```

`jj resolve --list` is the authoritative check; it prints "No conflicts found"
and exits 2 when none remain. The search catches markers left in edited
files, including the longer markers jj uses when content already contains
marker-like lines. Tests catch markers that are valid inside language strings.

A normal push refuses conflicts. The `--allow-conflicts` bypass
is forbidden, because remote conflict commits are hard to consume and hide
unfinished work.

Avoid fixing descendants one by one, `git checkout`, squashing to hide
conflicts, and bare resolve.

| need | command |
|---|---|
| current paths | `jj resolve --list` |
| all conflicted changes | `jj log -r 'conflicts()'` |
| manual | edit, then `jj st` |
| side #1/#2 | `jj resolve --tool :ours [paths...]` / `:theirs` |
| another rev | `jj restore --from <change-id> <path>` |
| drop change | `jj abandon <change-id>` |
| first conflict | `jj log -r 'roots(conflicts())'` |
