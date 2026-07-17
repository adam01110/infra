---
name: nix-index
description: Use this skill to locate which Nix package provides a command or file with `nix-locate` and the existing local database. Do not use it to build, refresh, inspect, or manage the `nix-index` database.
---

# Nix Index

Use `nix-locate` to map files/commands to packages. Do not run or manage `nix-index`.

Common queries:

```bash
nix-locate --top-level --whole-name --type x --type s '/bin/rg'
nix-locate --top-level --whole-name '/share/applications/firefox.desktop'
nix-locate --top-level --whole-name '/lib/libssl.so'
nix-locate --top-level --type x 'bin/(rg|ripgrep)'
nix-locate --top-level 'python.*/site-packages/pandas'
nix-locate --whole-name '/bin/hello'
```

Command-not-found workflow:

1. Try `nix-locate --top-level --whole-name --type x --type s "/bin/foo"`.
2. If empty, broaden to `nix-locate --top-level --type x 'bin/foo'` or regex.
3. If the file may live in a split output, retry without `--top-level`.
4. If still empty, fall back to `nix-search-tv`.

Result handling:

- Use `--top-level` for installable package attrs.
- Use `--whole-name` for known full paths.
- Add `--type x --type s` for executables.
- Multiple matches are normal; report the likely package first plus close alternatives.
- For too many results, add `--whole-name`, restrict the path such as `/bin/foo`, or add `--type` filters.
- For metadata, run `nix-search-tv preview --indexes nixpkgs <attr>`.
- Never suggest database build/refresh/delete/cache maintenance.
