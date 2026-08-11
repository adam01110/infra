---
name: nix-index
description: Locate Nix packages providing commands or files with nix-locate and the existing local database; never manage that database.
---

# nix index

need package owning command/file? use `nix-locate`. never run or manage `nix-index`; never suggest database build, refresh, deletion, or cache maintenance.

```bash
nix-locate --top-level --whole-name --type x --type s '/bin/rg'
nix-locate --top-level --whole-name '/share/applications/firefox.desktop'
nix-locate --top-level --whole-name '/lib/libssl.so'
nix-locate --top-level --type x 'bin/(rg|ripgrep)'
nix-locate --top-level 'python.*/site-packages/pandas'
nix-locate --whole-name '/bin/hello'
```

command missing:

1. exact executable: `nix-locate --top-level --whole-name --type x --type s "/bin/foo"`.
2. empty? broaden: `nix-locate --top-level --type x 'bin/foo'` or regex.
3. split output possible? retry without `--top-level`.
4. still empty? fall back to `nix-search-tv`.

need installable attrs? `--top-level`. known path? `--whole-name`. executable? `--type x --type s`. too broad? narrow path and type.

multiple matches normal. likely package first; close alternatives after. metadata needed? `nix-search-tv preview --indexes nixpkgs <attr>`.
