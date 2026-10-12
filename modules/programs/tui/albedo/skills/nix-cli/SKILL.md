---
name: nix-cli
description: >-
  Use before Nix package runs, shells, builds, development environments,
  flake updates, or requested NixOS, Home Manager, and nix-darwin rebuilds.
  Prefer eh and nh.
---

# nix cli

## permission

no explicit user request? no system rebuild or activation. build-only too.
verification not permission. no system toplevel build through another tool.
home activation? explicit request too. build request != switch/test/boot.

## tool

- packages? `eh run`, `eh shell`, `eh build`, `eh develop`, `eh info`.
- requested flake update? `eh update`.
- requested config rebuild? `nh os`, `nh home`, `nh darwin`.
  not `nixos-rebuild`, `home-manager`, `darwin-rebuild`.
- command missing? `, command args...`. comma fails?
  `eh run nixpkgs#package`; check argument forwarding first.
- no helper equivalent? raw `nix` fine: eval, repl, fmt, etc.

## execute

1. narrowest requested operation. flake/host/home target? inspect, never guess.
2. flags or forwarding unclear? subcommand `--help` first.
3. root needed? load `sudo` skill.
4. harness execution. explicit subcommands, not shell aliases.
   no permanent install or input update unless asked.
   helper fails? inspect error. no raw rebuild fallback.
5. check exit status. report operation + result. built != activated.

config edit, no rebuild request? focused eval, fmt, non-rebuild tests.
activation not checked? say so.
