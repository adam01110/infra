---
name: nix-index
description: Use this skill to locate which Nix package provides a command or file with `nix-locate` and the existing local database. Do not use it to build, refresh, inspect, or manage the `nix-index` database.
---

# Nix Index

Use this skill to map files to packages.

## Core Commands

Find the package that provides a command:

```bash
nix-locate --top-level --whole-name --type x --type s '/bin/rg'
```

Find the package that provides any file path:

```bash
nix-locate --top-level --whole-name '/share/applications/firefox.desktop'
nix-locate --top-level --whole-name '/lib/libssl.so'
```

Search more loosely when the exact path is unknown:

```bash
nix-locate --top-level --type x 'bin/(rg|ripgrep)'
nix-locate --top-level 'python.*/site-packages/pandas'
```

Inspect all outputs instead of only top-level packages when necessary:

```bash
nix-locate --whole-name '/bin/hello'
```

## Command-Not-Found Workflow

If the user asks which package provides a missing command, prefer `nix-locate` over generic `nix search`.

For a missing executable `foo`, try:

```bash
nix-locate --top-level --whole-name --type x --type s "/bin/foo"
```

If nothing matches, broaden the query:

```bash
nix-locate --top-level --type x 'bin/foo'
nix-locate --top-level --type x 'bin/.+foo.+'
```

## Restrictions

- Do not run `nix-index`.
- Do not explain how to build, refresh, delete, or inspect the database.
- Do not tell the user to manage cache paths.
- If lookup fails, broaden the `nix-locate` query or fall back to `nix-search-tv`.

## Result Handling

- Prefer `--top-level` when the user wants an installable package attribute.
- Prefer `--whole-name` when the full file path is known.
- Add `--type x --type s` for executable lookup.
- Treat multiple matches as normal; report the most likely package first, then mention close alternatives.
- If the user wants package metadata, follow up with `nix-search-tv preview --offline --indexes nixpkgs <attr>`.
- If `nix-locate` does not find a match, stay in query mode rather than switching to database maintenance steps.

## Common Patterns

Resolve a binary name to a package:

```bash
nix-locate --top-level --whole-name --type x --type s '/bin/git'
```

Resolve a desktop file to a package:

```bash
nix-locate --top-level --whole-name '/share/applications/org.gnome.Calculator.desktop'
```

Resolve a shared library to a package:

```bash
nix-locate --top-level --whole-name '/lib/libzstd.so'
```

## Troubleshooting

No results:

- Remove `--whole-name` and search with a broader regex.
- Remove `--top-level` if the file may live in a split output.
- Fall back to `nix-search-tv` if a broader `nix-locate` query still does not help.

Too many results:

- Add `--whole-name`.
- Restrict the path, such as `/bin/foo` instead of `foo`.
- Add `--type` filters.
