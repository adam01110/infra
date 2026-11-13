---
name: nix-cli
description: >-
  Use before Nix package runs, shells, builds, development environments,
  flake updates, or requested NixOS, Home Manager, and nix-darwin rebuilds.
  Prefer eh and nh.
license: AGPL-3.0-only
metadata:
  author: Adam0
  version: "1.0.0"
  short-description: Run Nix packages, shells, builds and rebuilds
---

# nix cli

## Permission

The build and activation rule lives in the system instructions. It also
covers building a system toplevel or home generation through another tool,
such as `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`.
A single package, check, or wrapper (`eh build .#pkg`) is not a configuration
build.

## Tools

- Packages: `eh run`, `eh shell`, `eh build`, `eh develop`, `eh info`. Without
  a terminal, run a command inside a dev shell with
  `eh develop [installable] -- -c <command> args...`.
- Requested flake update: `eh update <input>...` naming the inputs; bare
  `eh update` prompts for a selection and hangs without a terminal. To update
  everything, use `nix flake update`.
- Config builds and requested rebuilds: `nh os`, `nh home`, `nh darwin`, not
  `nixos-rebuild`, `home-manager`, or `darwin-rebuild`.
- Missing command: `run(",", "command", *args)`. If comma fails, use
  `eh run nixpkgs#package`; check argument forwarding first.
- No helper equivalent: raw `nix` is fine (eval, repl, fmt, etc.).
- Nix flags go after `--`, which ends eh's own arguments:

  ```text
  eh build .#pkg -- --no-link -L --keep-going
  ```

- Program arguments through `eh run` need a second `--`, because the first
  ends eh's arguments and the second ends `nix run`'s:
  `eh run nixpkgs#package -- -- args...`.

## Raw nix exceptions

Translate raw `nix` run, shell, build, and develop commands from scripts, docs,
or memory into eh before running them. Two cases need raw `nix` because eh
cannot do them:

- `--file` or `--expr` with `build`, `run`, or `shell`. Before running Nix, eh
  evaluates the first non-flag argument as a flake installable, so a file path
  or expression fails with exit code 12. Use `nix build --file ...` or
  `nix build --expr ...` directly.
- Reading the output of a build that succeeds, such as passing test lines from
  a check. `eh build` discards Nix output when the build succeeds, so use
  `nix build -L ...`. A failed `eh build` prints the full output, so debug
  failures with `eh build .#pkg -- -L`.

## Execute

1. Run the narrowest requested operation. Inspect flake, host, or home
   targets instead of guessing.
2. Flags or forwarding unclear: read subcommand `--help` first.
3. Root needed: load the `sudo` skill.
4. Use harness execution and explicit subcommands, not shell aliases. No
   permanent install or input update unless asked. If a helper fails, inspect
   the error; no raw rebuild fallback.
5. Check the exit status. Report operation and result; built != activated.
