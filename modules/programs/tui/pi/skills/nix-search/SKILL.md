---
name: nix-search
description: >-
  Use when the required Nix package or NixOS, Home Manager, flake, or custom
  module option is unknown.
license: AGPL-3.0-only
compatibility: Requires nix-search-tv and access to its configured indexes.
metadata:
  author: Adam0
  version: "1.0.0"
  short-description: Search Nix packages and module options
allowed-tools: bash
---

# nix search

package or option unknown? use `nix-search-tv`.

builtin indexes: `home-manager`, `nixos`, `nixpkgs`, `noogle`, `nur`.

custom options: `authentik-nix`, `determinate`, `disko`, `home-manager-nixos`,
`hylix`, `lanzaboote`, `nix-flatpak`, `nix-index-database`, `nixcord`,
`noctalia`, `nvf`, `overzicht`, `sops-nix`, `sops-nix-home-manager`,
`spicetify-nix`, `stylix`, `stylix-home-manager`, `zen-browser`.

repo wiring: builtin via `settings.indexes`; custom via
`settings.experimental.options_file`. both queried with `--indexes <name>`.

```bash
nix-search-tv print --indexes nixpkgs
nix-search-tv print --indexes nixpkgs,home-manager
nix-search-tv print --indexes stylix,stylix-home-manager
nix-search-tv preview --indexes nixpkgs firefox
nix-search-tv preview --indexes nixos boot.loader.systemd-boot.enable
nix-search-tv preview --indexes zen-browser enable
nix-search-tv preview --indexes nixpkgs --json firefox
nix-search-tv source --indexes authentik-nix services.authentik
nix-search-tv source --indexes noctalia programs.noctalia.settings.bar
nix-search-tv homepage --indexes nixpkgs firefox
```

first run builds index data; later uses cache. `cache.txt` missing? run
`print --indexes <source>` once. stale? remove
`~/.cache/nix-search-tv/<source-name>` then rerun.

ambiguity possible? explicit `--indexes`. parse output? `NO_COLOR=1`;
automation? `preview --json`, selected key in `_key`. `print` prefixes source,
e.g. `stylix/ stylix.image`.

```bash
nix-search-tv print --indexes nixpkgs | rg -i firefox
nix-search-tv preview --indexes nixpkgs --json firefox | jq -r '.description'
nix-search-tv source --indexes nixpkgs firefox
```
