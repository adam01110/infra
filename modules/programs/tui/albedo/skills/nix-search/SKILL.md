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
---

# nix search

Use `nix-search-tv` when a package or option is unknown.

Builtin indexes: `home-manager`, `nixos`, `nixpkgs`, `noogle`, `nur`.

Custom option indexes: `authentik-nix`, `determinate`, `disko`,
`home-manager-nixos`, `hylix`, `lanzaboote`, `nix-flatpak`,
`nix-index-database`, `nixcord`, `nvf`, `overzicht`, `sops-nix`,
`sops-nix-home-manager`, `spicetify-nix`, `stylix`, `stylix-home-manager`,
`zen-browser`.

The repo wires builtin indexes through `settings.indexes` and custom ones
through `settings.experimental.options_file`. Query both with
`--indexes <name>`.

```bash
nix-search-tv print --indexes nixpkgs
nix-search-tv print --indexes nixpkgs,home-manager
nix-search-tv print --indexes stylix,stylix-home-manager
nix-search-tv preview --indexes nixpkgs firefox
nix-search-tv preview --indexes nixos boot.loader.systemd-boot.enable
nix-search-tv preview --indexes zen-browser enable
nix-search-tv preview --indexes nixpkgs --json firefox
nix-search-tv source --indexes authentik-nix services.authentik
nix-search-tv source --indexes home-manager programs.noctalia.settings
nix-search-tv homepage --indexes nixpkgs firefox
```

The first run builds index data; later runs use cache. If `cache.txt` is
missing, run `print --indexes <source>` once. If data looks stale, tell the
user; do not delete the cache yourself.

- Pass explicit `--indexes` when ambiguity is possible.
- Set `NO_COLOR=1` when parsing output.
- For automation, use `preview --json`; the selected key is in `_key`.
- `print` prefixes each entry with its source, e.g. `stylix/ stylix.image`.

There is no shell; chain `run()` with `.pipe()` or filter in Python:

```python
job = run("nix-search-tv", "print", "--indexes", "nixpkgs", env={"NO_COLOR": "1"})
job = job.pipe("rg", "-i", "firefox")
await job
args = ["preview", "--indexes", "nixpkgs", "--json", "firefox"]
info = json.loads(await run("nix-search-tv", *args).text())
```
