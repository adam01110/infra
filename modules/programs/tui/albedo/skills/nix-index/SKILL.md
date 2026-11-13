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
---

# nix index

Use `nix-locate` to find the package owning a command or file. Do not run or
manage `nix-index`, and do not suggest database build, refresh, deletion, or
cache maintenance. Run it through `run()`; the lines below are its arguments.

```text
nix-locate --whole-name --at-root --type x --type s /bin/rg
nix-locate --whole-name --at-root /share/applications/firefox.desktop
nix-locate --whole-name /lib/libssl.so
nix-locate --regex --at-root --type x '/bin/(rg|ripgrep)$'
nix-locate --regex 'python.*/site-packages/pandas/__init__.py'
```

For a missing command:

1. Exact executable:
   `nix-locate --whole-name --at-root --type x --type s /bin/foo`.
2. If empty, broaden: drop `--whole-name`, or use `--regex`.
3. Still empty: add `--all`, which also searches packages hidden from
   `nix-env -qa`, such as some split outputs.
4. Still empty: fall back to `nix-search-tv`.

Flags: `--whole-name` matches the basename exactly, `--at-root` anchors the
path at the package root, `--regex` enables regular expressions (otherwise the
pattern is literal), and `--type x --type s` limits to executables and
symlinks. If results are too broad, narrow the path and type.

Multiple matches are normal; list the likely package first, close alternatives
after. For metadata, run
`nix-search-tv preview --indexes nixpkgs <attr>`.
