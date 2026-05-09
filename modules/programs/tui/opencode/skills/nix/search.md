---
name: nix-search
description: Use this skill to search NixOS packages and options with `nix-search-tv`. Query package details, source locations, and configured NixOS, Home Manager, and flake option indexes.
---

# Nix Search

This skill helps you search NixOS packages and options using `nix-search-tv`, a tool that indexes packages and options from builtin upstream indexes plus this repo's filtered custom option sources.

## Available Sources

Common builtins:

- `nixpkgs` for packages.
- `home-manager` for Home Manager options.
- `nixos` for NixOS options.
- `nur` for NUR packages.
- `noogle` for function and library docs.

Configured custom option sources:

- `disko` for Disko NixOS options.
- `home-manager-nixos` for the Home Manager NixOS module.
- `lanzaboote` for Lanzaboote NixOS options.
- `nix-flatpak` for the nix-flatpak Home Manager module.
- `nix-index-database` for the nix-index-database Home Manager module.
- `nixcord` for nixcord options.
- `noctalia` for the Noctalia Home Manager module.
- `nvf` for NVF options.
- `overzicht` for the Overzicht Home Manager module.
- `sops-nix` for SOPS NixOS options.
- `sops-nix-home-manager` for SOPS Home Manager options.
- `spicetify-nix` for Spicetify Home Manager options.
- `stylix` for Stylix NixOS options.
- `stylix-home-manager` for Stylix Home Manager options.
- `zen-browser` for the Zen Browser Home Manager module.

The repo wires builtin upstream indexes through `settings.indexes` and the custom sources above through `settings.experimental.options_file`.
They are still selected with the same `--indexes <name>` CLI flag.

## Commands

### 1. List Available Packages or Options

Use `print` to list entries from one or more builtin or custom sources:

```bash
nix-search-tv print --indexes nixpkgs
nix-search-tv print --indexes nixos
nix-search-tv print --indexes nixpkgs,home-manager
nix-search-tv print --indexes stylix,stylix-home-manager
```

Use cached data without refetching:

```bash
nix-search-tv print --indexes nixpkgs
```

Search through package or option names:

```bash
nix-search-tv print --indexes nixpkgs | grep -i firefox
nix-search-tv print --indexes noctalia | grep -i panel
```

The first run downloads and indexes data, so it can take a few minutes.

### 2. Get Package or Option Details

Use `preview` to inspect a package or option from a specific source:

```bash
nix-search-tv preview --indexes nixpkgs firefox
nix-search-tv preview --indexes nixos boot.loader.systemd-boot.enable
nix-search-tv preview --indexes stylix-home-manager stylix.targets.gtk.enable
```

Use JSON output for automation:

```bash
nix-search-tv preview --indexes nixpkgs --json firefox
```

The `--json` flag returns structured output and includes the selected key in `_key`.

### 3. Get Source Code Location

Use `source` to get the source location for a package or option:

```bash
nix-search-tv source --indexes nixpkgs firefox
nix-search-tv source --indexes noctalia programs.noctalia-shell.settings.bar
```

### 4. Get Homepage

Use `homepage` to get a package homepage URL:

```bash
nix-search-tv homepage --indexes nixpkgs firefox
```

## Tips

- First run downloads and indexes data. Later runs reuse the cache.
- `print` prefixes entries with the source name, for example `stylix/ stylix.image`.
- Some custom sources intentionally share namespaces, such as `stylix` and `stylix-home-manager`, so duplicate-looking option names can appear across sources.
- Set `NO_COLOR=1` to disable ANSI colors in command output.
- Use `--json` with `preview` when the result will be parsed by tools.

## Agent Usage Patterns

### Efficient cached lookup

```bash
nix-search-tv preview --indexes nixpkgs --json firefox | jq -r '.description'
```

### Search and get source in one pipeline

```bash
PACKAGE=$(nix-search-tv print --indexes nixpkgs | grep -i neovim | head -1)
nix-search-tv source --indexes nixpkgs "$PACKAGE"
```

### Inspect configured flake indexes

```bash
nix-search-tv print --indexes stylix
nix-search-tv print --indexes stylix-home-manager
nix-search-tv preview --indexes zen-browser enable
```

## Troubleshooting

`cache.txt` not found: run `nix-search-tv print --indexes <source>` to trigger initial indexing.

Stale data: remove the relevant cache directory and rerun a query:

```bash
rm -rf ~/.cache/nix-search-tv/<source-name>
nix-search-tv print --indexes <source-name>
```

Multiple sources causing ambiguity: use an explicit `--indexes` list.
