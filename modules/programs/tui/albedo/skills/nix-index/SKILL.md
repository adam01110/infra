---
name: nix-index
description: >-
  Use when identifying which Nix package provides a command, executable,
  library, desktop entry, module, or other file.
license: AGPL-3.0-only
compatibility: Requires nix-locate and an existing local nix-index database.
metadata:
  author: Adam0
  version: "1.0.0"
  short-description: Find Nix packages that provide files
allowed-tools: bash
---

# nix index

Use `nix-locate` to find the package owning a command or file. Do not run or
manage `nix-index`, and do not suggest database build, refresh, deletion, or
cache maintenance.

```bash
nix-locate --top-level --whole-name --type x --type s '/bin/rg'
nix-locate --top-level --whole-name '/share/applications/firefox.desktop'
nix-locate --top-level --whole-name '/lib/libssl.so'
nix-locate --top-level --type x 'bin/(rg|ripgrep)'
nix-locate --top-level 'python.*/site-packages/pandas'
nix-locate --whole-name '/bin/hello'
```

For a missing command:

1. Exact executable:
   `nix-locate --top-level --whole-name --type x --type s "/bin/foo"`.
2. If empty, broaden: `nix-locate --top-level --type x 'bin/foo'` or a regex.
3. If the package may have split outputs, retry without `--top-level`.
4. Still empty: fall back to `nix-search-tv`.

Flags: `--top-level` for installable attrs, `--whole-name` for a known path,
`--type x --type s` for executables. If results are too broad, narrow the path
and type.

Multiple matches are normal; list the likely package first, close alternatives
after. For metadata, run
`nix-search-tv preview --indexes nixpkgs <attr>`.
