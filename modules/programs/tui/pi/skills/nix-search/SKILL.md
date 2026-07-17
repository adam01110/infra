---
name: nix-search
description: Use this skill to search NixOS packages and options with `nix-search-tv`. Query package details, source locations, and configured NixOS, Home Manager, and flake option indexes.
---

# Nix Search

Use `nix-search-tv` for packages/options. Builtin indexes: `home-manager`, `nixos`, `nixpkgs`, `noogle`, `nur`. Custom option indexes: `authentik-nix`, `determinate`, `disko`, `home-manager-nixos`, `hylix`, `lanzaboote`, `nix-flatpak`, `nix-index-database`, `nixcord`, `noctalia`, `nvf`, `overzicht`, `sops-nix`, `sops-nix-home-manager`, `spicetify-nix`, `stylix`, `stylix-home-manager`, `zen-browser`.

This repo wires builtin indexes through `settings.indexes` and custom option sources through `settings.experimental.options_file`; both use `--indexes <name>`.

Commands:

```bash
nix-search-tv print --indexes nixpkgs
nix-search-tv print --indexes nixpkgs,home-manager
nix-search-tv print --indexes stylix,stylix-home-manager
nix-search-tv preview --indexes nixpkgs firefox
nix-search-tv preview --indexes nixos boot.loader.systemd-boot.enable
nix-search-tv preview --indexes zen-browser enable
nix-search-tv preview --indexes nixpkgs --json firefox
nix-search-tv source --indexes authentik-nix services.authentik
nix-search-tv source --indexes noctalia programs.noctalia-shell.settings.bar
nix-search-tv homepage --indexes nixpkgs firefox
```

Notes:

- First run indexes data; later runs use cache.
- `print` prefixes source names, e.g. `stylix/ stylix.image`.
- Use explicit `--indexes` to avoid ambiguity across custom sources.
- Use `NO_COLOR=1` for parseable output.
- Use `--json` with `preview` for automation; selected key appears in `_key`.
- If `cache.txt` is missing, run `print --indexes <source>` once.
- If stale, remove `~/.cache/nix-search-tv/<source-name>` and rerun.

Patterns:

```bash
nix-search-tv print --indexes nixpkgs | rg -i firefox
nix-search-tv preview --indexes nixpkgs --json firefox | jq -r '.description'
nix-search-tv source --indexes nixpkgs firefox
```
