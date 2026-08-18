# compact templates

assume/tested jj 0.44.0. use commands as written. top-level `--no-pager`
intentional. inline `-T` keeps repo/global config untouched. parse failure means
version drift; inspect `jj <command> --help` and `jj help -k templates`.

## log

<!-- rumdl-disable MD013 -->

```bash
jj --no-pager log --no-graph -n 20 -T 'change_id.shortest(8) ++ if(bookmarks, " " ++ bookmarks, "") ++ if(current_working_copy, " @", "") ++ if(empty, " (empty)", "") ++ if(conflict, " (conflict)", "") ++ " " ++ if(description, description.first_line(), "(no description)") ++ "\n"'
```

<!-- rumdl-enable MD013 -->

keeps stable 8-char change ID, bookmarks/`@`, empty/conflict, first
description. bare `shortest()` may collapse to one char.

## show

<!-- rumdl-disable MD013 -->

```bash
jj --no-pager show <change-id> --stat -T 'change_id.shortest(8) ++ if(bookmarks, " " ++ bookmarks, "") ++ if(current_working_copy, " @", "") ++ if(empty, " (empty)", "") ++ if(conflict, " (conflict)", "") ++ " " ++ if(description, description.first_line(), "(no description)") ++ "\n"'
```

<!-- rumdl-enable MD013 -->

need no file summary? replace `--stat` with `--no-patch`.

## diff

<!-- rumdl-disable MD013 -->

```bash
jj --no-pager diff -T 'self.status_char() ++ " " ++ self.display_diff_path() ++ "\n"'
```

<!-- rumdl-enable MD013 -->

specific revision? add `-r <rev>`.

## bookmark list

<!-- rumdl-disable MD013 -->

```bash
jj --no-pager bookmark list -T 'if(self.normal_target(), self.name() ++ ": " ++ self.normal_target().change_id().shortest(8) ++ " " ++ if(self.normal_target().description(), self.normal_target().description().first_line(), "(no description)") ++ "\n", self.name() ++ ": (conflicted)\n")'
```

<!-- rumdl-enable MD013 -->

conflicted bookmark target details needed? default output.

## workspace list

<!-- rumdl-disable MD013 -->

```bash
jj --no-pager workspace list -T 'self.name() ++ ": " ++ if(self.root(), self.root().absolute(), "(root unavailable)") ++ " | " ++ self.target().change_id().shortest(8) ++ " " ++ if(self.target().description(), self.target().description().first_line(), "(no description)") ++ if(self.target().empty(), " (empty)", "") ++ "\n"'
```

<!-- rumdl-enable MD013 -->

## operation log

<!-- rumdl-disable MD013 -->

```bash
jj --no-pager op log --no-graph -n 20 -T 'id.short(8) ++ " " ++ time.start().ago() ++ " " ++ description.first_line() ++ "\n"'
```

<!-- rumdl-enable MD013 -->

recovery context first. `-p` only after relevant IDs narrowed.

## evolution log

<!-- rumdl-disable MD013 -->

```bash
jj --no-pager evolog -r <change-id> --no-graph -n 20 -T 'commit.change_id().shortest(8) ++ " " ++ if(commit.description(), commit.description().first_line(), "(no description)") ++ " | " ++ operation.id().short(8) ++ " " ++ operation.description().first_line() ++ "\n"'
```

<!-- rumdl-enable MD013 -->

change summary left; rewriting operation right.

`jj st`/`status` expose no template in 0.44.0. side-effect commands such as undo,
op restore, resolve need no template.
