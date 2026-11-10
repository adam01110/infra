---
name: nix-cli
description: >-
  Use before Nix package runs, shells, builds, development environments,
  flake updates, or requested NixOS, Home Manager, and nix-darwin rebuilds.
  Prefer eh and nh.
---

# nix cli

## Permission

Build, switch, test, boot, or activate a system or home configuration only
when the user explicitly asks; build-only runs (`nh os build`, `nh home build`,
`nh darwin build`) count too. Needing to verify a change is not permission, and
neither is building the system toplevel through another tool. A build request
does not cover switch, test, or boot.

## Tools

- Packages: `eh run`, `eh shell`, `eh build`, `eh develop`, `eh info`.
- Requested flake update: `eh update`.
- Config builds and requested rebuilds: `nh os`, `nh home`, `nh darwin`, not
  `nixos-rebuild`, `home-manager`, or `darwin-rebuild`.
- Missing command: `, command args...`. If comma fails, use
  `eh run nixpkgs#package`; check argument forwarding first.
- No helper equivalent: raw `nix` is fine (eval, repl, fmt, etc.).

## Execute

1. Run the narrowest requested operation. Inspect flake, host, or home
   targets instead of guessing.
2. Flags or forwarding unclear: read subcommand `--help` first.
3. Root needed: load the `sudo` skill.
4. Use harness execution and explicit subcommands, not shell aliases. No
   permanent install or input update unless asked. If a helper fails, inspect
   the error; no raw rebuild fallback.
5. Check the exit status. Report operation and result; built != activated.

Config edit without a rebuild request: verify with focused eval, fmt, and
tests that do not rebuild. Say that activation was not checked.
