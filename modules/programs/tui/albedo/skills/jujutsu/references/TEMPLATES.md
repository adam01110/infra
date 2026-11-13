# Compact templates

Use the commands as written. The top-level `--no-pager`
is intentional, and inline `-T` leaves repo and global config untouched. A parse
failure means version drift; check `jj <command> --help` and
`jj help -k templates`.

## Log

<!-- rumdl-disable MD013 -->

```bash
jj --no-pager log --no-graph -n 20 -T 'change_id.shortest(8) ++ if(bookmarks, " " ++ bookmarks, "") ++ if(current_working_copy, " @", "") ++ if(empty, " (empty)", "") ++ if(conflict, " (conflict)", "") ++ " " ++ if(description, description.first_line(), "(no description)") ++ "\n"'
```

<!-- rumdl-enable MD013 -->

Shows a stable 8-char change ID, bookmarks and `@`, empty/conflict flags, and
the first description line. Bare `shortest()` may collapse to one character.

## Show

<!-- rumdl-disable MD013 -->

```bash
jj --no-pager show <change-id> --stat -T 'change_id.shortest(8) ++ if(bookmarks, " " ++ bookmarks, "") ++ if(current_working_copy, " @", "") ++ if(empty, " (empty)", "") ++ if(conflict, " (conflict)", "") ++ " " ++ if(description, description.first_line(), "(no description)") ++ "\n"'
```

<!-- rumdl-enable MD013 -->

To drop the file summary, replace `--stat` with `--no-patch`.

## Diff

<!-- rumdl-disable MD013 -->

```bash
jj --no-pager diff -T 'self.status_char() ++ " " ++ self.display_diff_path() ++ "\n"'
```

<!-- rumdl-enable MD013 -->

For a specific revision, add `-r <rev>`.

## Bookmark list

<!-- rumdl-disable MD013 -->

```bash
jj --no-pager bookmark list -T 'self.name() ++ if(self.remote(), "@" ++ self.remote(), "") ++ ": " ++ if(self.normal_target(), self.normal_target().change_id().shortest(8) ++ " " ++ if(self.normal_target().description(), self.normal_target().description().first_line(), "(no description)"), "(conflicted)") ++ "\n"'
```

<!-- rumdl-enable MD013 -->

For conflicted bookmark target details, use the default output.

## Workspace list

<!-- rumdl-disable MD013 -->

```bash
jj --no-pager workspace list -T 'self.name() ++ ": " ++ if(self.root(), self.root().absolute(), "(root unavailable)") ++ " | " ++ self.target().change_id().shortest(8) ++ " " ++ if(self.target().description(), self.target().description().first_line(), "(no description)") ++ if(self.target().empty(), " (empty)", "") ++ "\n"'
```

<!-- rumdl-enable MD013 -->

## Operation log

<!-- rumdl-disable MD013 -->

```bash
jj --no-pager op log --no-graph -n 20 -T 'id.short(8) ++ " " ++ time.start().ago() ++ " " ++ description.first_line() ++ "\n"'
```

<!-- rumdl-enable MD013 -->

Get recovery context first; use `-p` only after narrowing to the relevant IDs.

## Evolution log

<!-- rumdl-disable MD013 -->

```bash
jj --no-pager evolog -r <change-id> --no-graph -n 20 -T 'commit.change_id().shortest(8) ++ " " ++ if(commit.description(), commit.description().first_line(), "(no description)") ++ " | " ++ operation.id().short(8) ++ " " ++ operation.description().first_line() ++ "\n"'
```

<!-- rumdl-enable MD013 -->

The change summary is on the left; the rewriting operation is on the right.

`jj st`/`status` takes no template. Side-effect commands such as undo,
op restore, and resolve need no template.
