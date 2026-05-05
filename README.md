<div align="center">
  <img src="./face.png" alt="Avatar" width="112" />
  <img src="./modules/home/cli/fastfetch/logo.png" alt="Nix logo" width="112" />

  # adam0's NixOS configuration

  Modular multi-host NixOS and Home Manager flake for desktop, laptop, and virtual machine systems.

  [![CI](https://img.shields.io/github/actions/workflow/status/adam01110/nixos/ci.yml?branch=main&style=flat-square&label=CI&labelColor=504945&color=cc241d)](https://github.com/adam01110/nixos/actions/workflows/ci.yml)
  [![Repo Size](https://img.shields.io/github/repo-size/adam01110/nixos?style=flat-square&label=repo%20size&labelColor=504945&color=3c3836)](https://github.com/adam01110/nixos)
  <br />
  [![NixOS](https://img.shields.io/badge/NixOS-unstable-458588?style=flat-square&labelColor=504945&logo=nixos&logoColor=ebdbb2)](https://nixos.org)
  [![Flakes](https://img.shields.io/badge/Nix-flakes-689d6a?style=flat-square&labelColor=504945&logo=nixos&logoColor=ebdbb2)](https://nixos.wiki/wiki/Flakes)
  [![Home Manager](https://img.shields.io/badge/Home%20Manager-managed-b16286?style=flat-square&labelColor=504945&logo=nixos&logoColor=ebdbb2)](https://github.com/nix-community/home-manager)
  [![Stylix](https://img.shields.io/badge/Stylix-theming-8f3f71?style=flat-square&labelColor=504945&logo=nixos&logoColor=ebdbb2)](https://github.com/danth/stylix)
  [![SOPS Nix](https://img.shields.io/badge/SOPS%20Nix-secrets-fe8019?style=flat-square&labelColor=504945&logo=nixos&logoColor=ebdbb2)](https://github.com/Mic92/sops-nix)
  [![Disko](https://img.shields.io/badge/Disko-managed%20storage-98971a?style=flat-square&labelColor=504945&logo=nixos&logoColor=ebdbb2)](https://github.com/nix-community/disko)
  [![Lanzaboote](https://img.shields.io/badge/Lanzaboote-secure%20boot-458588?style=flat-square&labelColor=504945&logo=nixos&logoColor=ebdbb2)](https://github.com/nix-community/lanzaboote)

  [Overview](#overview) - [Hosts](#hosts) - [Usage](#usage) - [Secrets](#secrets) - [Customization](#Customization) - [Tooling](#Tooling)
</div>

This repository contains a personal NixOS setup built around `flake-parts`, `Home Manager`, and a heavily modular directory layout. It shares a common base across multiple machines, then layers host-specific hardware, service, and desktop overrides on top.

## Overview

- Shared NixOS modules under `modules/system`, Home Manager modules under `modules/home`, and per-host overrides under `modules/hosts`.
- Three flake outputs: `desktop`, `laptop`, and `vm`, all created from the same module stack in `flake/nixos.nix`.
- Declarative storage with `Disko`, encrypted secrets with `Sops-nix`, Secure Boot with `Lanzaboote`, and theming through `Stylix`.
- Desktop built on `Hyprland`, `UWSM`, `greetd` + `tuigreet`, and `Noctalia Shell`.

## Hosts

| Host | Purpose | Notable differences |
| --- | --- | --- |
| `desktop` | Main workstation | ROCm enabled, dual-monitor Hyprland layout, Wooting and Roccat support, AMD + Intel GPU monitoring |
| `laptop` | Mobile system | Wi-Fi, Bluetooth, TLP, SCX, lid switch handling, battery-oriented tuning, touch support |
| `vm` | QEMU/KVM guest | `/dev/vda` Disko target, SSH enabled, guest agents, simplified display setup |

## Usage

From the repository root:

```bash
# Inspect flake outputs
nix flake show

# Apply a host configuration
sudo nixos-rebuild switch --flake .#desktop

# Format the repository
nix fmt

# Enter the dev shell
nix develop
```

> [!IMPORTANT]
> The host modules point at real installation devices such as `/dev/nvme0n1` and `/dev/vda`, and the configuration expects an Age key at `/var/lib/sops-nix/key.txt`. Review `modules/hosts/*/default.nix`, `modules/system/disk.nix`, and `modules/system/sops.nix` before using this on a new machine.

## Secrets

- Secrets live in `secrets/secrets.yaml` and are managed with Sops-nix.
- Recipient rules are defined in `.sops.yaml` for one user key and three host Age keys.

Edit flow:

```bash
sops secrets/secrets.yaml
```

## Customization

- Edit shared identity, locale, and Git metadata in `vars.nix`.
- Adjust host-specific hardware and service choices in `modules/hosts/<host>/`.
- Add or override shared behavior in `modules/system/` and `modules/home/`.
- Extend package selection through `pkgs/` and `overlays/`.

## Tooling

- Formatting and linting are wired through `treefmt` in `flake/treefmt.nix`.
- The repository uses `import-tree` extensively to auto-discover modules, overlays, and local packages.

## Licensing

- This repository is mixed-license. The root `LICENSE` file contains the `AGPL-3.0-or-later` text intended for original work authored for this repository, unless a file says otherwise.
- Files derived from Nixpkgs are kept under MIT-compatible treatment with upstream attribution preserved. See `pkgs/lutris.nix`, `pkgs/zaread.nix`, and `THIRD_PARTY_NOTICES.md`.
- Adapter scripts adapted from `ripgrep-all` discussion posts are marked as adapted third-party material with provenance notices. They are not being confidently relabeled as `AGPL-3.0-or-later` without a clearer relicensing basis.
- Other copied or vendored third-party material keeps its own attribution and should be reviewed under `THIRD_PARTY_NOTICES.md` rather than assumed to follow the repo default.
