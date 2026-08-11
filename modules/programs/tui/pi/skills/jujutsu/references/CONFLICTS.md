# conflicts

jj conflict is commit data. rebase/squash producing conflict succeeds; commit stays marked. further rebase allowed. push rejects conflicted history.

## inspect

```bash
jj st
jj resolve --list
jj resolve --list -r <change-id>
jj log
jj config get ui.conflict-marker-style
```

styles: `diff` modern default, `snapshot` full sides/base, `git` legacy 3-way.

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

side #1 = ours/destination, usually current line. side #2 = theirs/source, usually incoming/rebased line. resolve manual by replacing whole marker block with final content.

## choose path

bare `jj resolve` launches interactive merge tool. agent? never.

1. complex merge: edit markers directly, then `jj st`.
2. one side wholly correct:

```bash
jj resolve --tool :ours
jj resolve --tool :theirs
jj resolve --tool :ours path/to/file.rs
```

3. another revision correct:

```bash
jj restore --from <change-id> path/to/file.txt
```

4. change not worth keeping:

```bash
jj abandon <change-id>
```

descendants rebase; their conflicts remain.

5. same conflict repeated in descendants? resolve earliest conflicted ancestor once:

```bash
jj log -r 'conflicts()'
jj edit <ancestor-change-id>
# edit markers
jj st
jj edit <original-change-id>
```

jj re-propagates fix. record original ID before moving; never assume `@-` returns prior location.

## verify

status alone insufficient:

```bash
jj st
git grep -E '^(<{7}|>{7}|\\%{7}|\\+{7})' || echo 'no residual conflict markers'
# run project tests/linter
```

co-located? read-only `git grep` safe. non-colocated? `rg` or `grep -rE`. tests catch markers valid inside language strings.

push still refuses conflict; no force-conflicts option.

avoid descendant-by-descendant fixes, `git checkout`, squash-to-hide, and bare resolve.

| need | command |
|---|---|
| current paths | `jj resolve --list` |
| all conflicted changes | `jj log -r 'conflicts()'` |
| manual | edit, then `jj st` |
| side #1/#2 | `jj resolve --tool :ours [paths...]` / `:theirs` |
| another rev | `jj restore --from <change-id> <path>` |
| drop change | `jj abandon <change-id>` |
| first conflict | `jj log -r 'conflicts() ~ ::conflicts()-'` |
