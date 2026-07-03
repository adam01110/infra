<div align="center">
  <img src="./assets/face.png" alt="Avatar" width="112" />
  <img src="./assets/nix.png" alt="Nix logo" width="112" />

  # adam0's infra

  The Nix flake that keeps my desktop, laptop, and homelab server reproducible.

  [![Repo Size](https://img.shields.io/github/repo-size/adam01110/infra?style=flat-square&label=repo%20size&labelColor=504945&color=3c3836)](https://github.com/adam01110/infra)
  <br />
  [![NixOS](https://img.shields.io/badge/NixOS-unstable-458588?style=flat-square&labelColor=504945&logo=nixos&logoColor=ebdbb2)](https://nixos.org)
  [![Flakes](https://img.shields.io/badge/Nix-flakes-689d6a?style=flat-square&labelColor=504945&logo=nixos&logoColor=ebdbb2)](https://nixos.wiki/wiki/Flakes)
  [![Home Manager](https://img.shields.io/badge/Home%20Manager-managed-b16286?style=flat-square&labelColor=504945&logo=nixos&logoColor=ebdbb2)](https://github.com/nix-community/home-manager)
  [![Stylix](https://img.shields.io/badge/Stylix-theming-8f3f71?style=flat-square&labelColor=504945&logo=nixos&logoColor=ebdbb2)](https://github.com/danth/stylix)
  [![SOPS Nix](https://img.shields.io/badge/SOPS%20Nix-secrets-fe8019?style=flat-square&labelColor=504945&logo=nixos&logoColor=ebdbb2)](https://github.com/Mic92/sops-nix)
  [![Disko](https://img.shields.io/badge/Disko-storage-98971a?style=flat-square&labelColor=504945&logo=nixos&logoColor=ebdbb2)](https://github.com/nix-community/disko)

  [What This Is](#what-this-is) - [Machines](#machines) - [Layout](#layout)
</div>

This is my personal infrastructure repo. It is mostly here so I can rebuild my own machines without trying to remember every package, service, kernel tweak, browser preference, shell setting, and desktop detail by hand.

It is not meant to be a starter template. Some parts are reusable, but a lot of it is deliberately shaped around my hardware, my domains, my secrets layout, and the way I like my desktop to feel.

## What This Is

- A multi-host NixOS flake for my `desktop`, `laptop`, and `euclid` server.
- Home Manager configuration for the user-facing parts of my setup.
- A Hyprland desktop built around UWSM, tuigreet, Noctalia Shell, Stylix, Zen Browser, themed apps, and a lot of small quality-of-life modules.
- A homelab/server stack for services like Authentik, Traefik, WireGuard, CrowdSec, databases, notifications, and media-related tooling.
- Local packages, overlays, preview helpers, and small libraries that make the rest of the tree less repetitive.

The repo is wired with `flake-parts`, `flake-file`, and `import-tree`, so most of the structure is discovered from `modules/` instead of being manually listed in one giant flake file.

## Machines

| Host | What it is |
| --- | --- |
| `desktop` | Main workstation |
| `laptop` | Portable system |
| `euclid` | Homelab server |

## Layout

| Path | Purpose |
| --- | --- |
| `assets/` | README images and shared static assets |
| `lib/` | Small helper libraries for Hyprland, Stylix, MIME, Starship, Yazi, and environment handling |
| `modules/hosts/` | The actual machine entrypoints |
| `modules/desktop/` | Hyprland, Noctalia, greetd, UWSM, portals, clipboard, tablet, MangoHud, and desktop glue |
| `modules/programs/` | CLI, TUI, GUI, browser, Git, GPG, SSH, GTK, Java, and Nix-LD modules |
| `modules/services/` | Audio, networking, power, storage, containers, homelab services, and system tuning |
| `modules/profiles/` | Shared base, personal, server, gaming, partitioning, locale, and theming profiles |
| `modules/pkgs/` | Local packages, adapters, previews, and overlays |
| `modules/nix/` | Flake inputs, Nix settings, Home Manager, SOPS, kernel, firmware, and boot-related modules |
| `vars.nix` | Shared identity, Git metadata, locale, and domain defaults |
