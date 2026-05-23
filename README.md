<div align="center">
  <img src="./assets/face.png" alt="Avatar" width="112" />
  <img src="./assets/nix.png" alt="Nix logo" width="112" />

  # adam0's infrastructure

  NixOS and Home Manager flake for my system and user environment.

  [![Repo Size](https://img.shields.io/github/repo-size/adam01110/infra?style=flat-square&label=repo%20size&labelColor=504945&color=3c3836)](https://github.com/adam01110/infra)
  <br />
  [![NixOS](https://img.shields.io/badge/NixOS-unstable-458588?style=flat-square&labelColor=504945&logo=nixos&logoColor=ebdbb2)](https://nixos.org)
  [![Flakes](https://img.shields.io/badge/Nix-flakes-689d6a?style=flat-square&labelColor=504945&logo=nixos&logoColor=ebdbb2)](https://nixos.wiki/wiki/Flakes)
  [![Home Manager](https://img.shields.io/badge/Home%20Manager-modules-b16286?style=flat-square&labelColor=504945&logo=nixos&logoColor=ebdbb2)](https://github.com/nix-community/home-manager)
  [![Stylix](https://img.shields.io/badge/Stylix-theming-8f3f71?style=flat-square&labelColor=504945&logo=nixos&logoColor=ebdbb2)](https://github.com/danth/stylix)
  [![SOPS Nix](https://img.shields.io/badge/SOPS%20Nix-secrets-fe8019?style=flat-square&labelColor=504945&logo=nixos&logoColor=ebdbb2)](https://github.com/Mic92/sops-nix)
  [![Disko](https://img.shields.io/badge/Disko-storage-98971a?style=flat-square&labelColor=504945&logo=nixos&logoColor=ebdbb2)](https://github.com/nix-community/disko)

  [Overview](#overview) - [Layout](#layout) - [Usage](#usage) - [Secrets](#secrets) - [Customization](#customization) - [Tooling](#tooling)
</div>

This repository contains my NixOS and Home Manager setup. It uses `flake-parts`, `flake-file`, and `import-tree` to expose NixOS modules, Home Manager modules, overlays, packages, Disko layouts, and development tooling from `modules/`.

## Overview

- Public flake outputs are generated from `modules/` through `inputs.import-tree ./modules`.
- NixOS modules live under `modules/nix`, `modules/services`, `modules/profiles`, and top-level module files such as `modules/users.nix`.
- Home Manager modules live under `modules/programs`, `modules/desktop`, and shared profile modules.
- Desktop modules cover `Hyprland`, `UWSM`, `tuigreet`, `Noctalia Shell`, `Stylix`, XDG portals, MIME defaults, and TUI/GUI integration.
- Local packages, preview helpers, adapters, and overlays live under `modules/pkgs`. Shared helpers live under `lib/`.

## Layout

| Path | Purpose |
| --- | --- |
| `assets/` | README images, user avatar, and shared static assets |
| `lib/` | Small helper libraries for environment, MIME, Hyprland, Stylix, Starship, and Yazi config |
| `modules/desktop/` | Hyprland, Noctalia, UWSM, greetd, XDG, clipboard, tablet, and desktop integration modules |
| `modules/development/` | Dev shell and treefmt configuration |
| `modules/nix/` | Core flake, Nix, Home Manager, SOPS, kernel, firmware, and input wiring |
| `modules/pkgs/` | Local packages and package overlays |
| `modules/profiles/` | Shared system and Home Manager profiles, partitioning, locale, theming, and tuning |
| `modules/programs/` | CLI, TUI, GUI, Git, GPG, SSH, GTK, Java, and Nix-LD modules |
| `modules/services/` | NixOS service modules for audio, networking, power, storage, containers, and system tuning |
| `vars.nix` | Shared identity, Git metadata, locale, and regional defaults |

## Usage

From the repository root:

```bash
# Enter the development shell
nix develop

# Format and lint the repository
nix fmt

# Regenerate flake.nix after changing flake-file inputs
nix run .#write-flake
```

## Secrets

- Runtime secrets are kept outside this public repo in the private `adam01110/secrets` flake input.
- Recipient rules live in `.sops.yaml` for one user PGP key and three host Age keys.
- SOPS Nix is shared between NixOS and Home Manager through `modules/nix/sops.nix`.

Edit flow for the private secrets repository:

```bash
sops secrets.yaml
```

## Customization

- Edit shared identity, locale, and Git metadata in `vars.nix`.
- Add NixOS behavior through `modules/nix`, `modules/services`, and `modules/profiles`.
- Add user-facing tools through `modules/programs` and `modules/desktop`.
- Add local packages and overlays under `modules/pkgs`.

## Tooling

- `treefmt-nix` wires `alejandra`, `deadnix`, `statix`, `nixf-diagnose`, `keep-sorted`, `shellcheck`, `shfmt`, `stylua`, `rumdl-format`, and `yamllint`.
- `flake-file` owns the generated root `flake.nix`; update inputs in modules and regenerate with `nix run .#write-flake`.
- `import-tree` auto-discovers the module tree so most new modules only need to export the relevant flake attributes.
- The default dev shell currently provides `sops` and `tokei`.
