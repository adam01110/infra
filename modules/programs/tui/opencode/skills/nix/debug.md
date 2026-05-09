---
name: nix-debug
description: Use this skill to debug Nix expressions, flake outputs, modules, and option values with `nix repl`. Prefer it when investigating evaluation errors, missing attributes, unexpected option values, derivation inputs, or output structure. Use `nix repl` instead of `nix eval` for inspection because the interactive REPL is faster for repeated queries.
---

## Role

Debug Nix interactively. Prefer one `nix repl` session with repeated probes over many separate `nix eval` calls.

## Workflow

1. Start from the narrowest useful target.
2. Load the flake or expression into `nix repl`.
3. Inspect attribute names before drilling into deeper paths.
4. Evaluate subexpressions incrementally to isolate the failing edge.
5. Report the exact attr path, value, or error that explains the behavior.

## Core Commands

Load the current flake:

```bash
nix repl
:lf .
```

Load a specific Nix file when flake outputs are not the target:

```bash
nix repl ./path/to/file.nix
```

Inspect available top-level attrs before guessing paths:

```nix
builtins.attrNames inputs
builtins.attrNames packages
builtins.attrNames nixosConfigurations
builtins.attrNames homeConfigurations
```

Inspect a concrete value:

```nix
nixosConfigurations.<host>.config.networking.hostName
packages.${builtins.currentSystem}.default
```

Pretty-print larger values:

```nix
:p nixosConfigurations.<host>.config.environment.systemPackages
```

## Debug Patterns

Missing attribute:

1. Check each parent attrset with `builtins.attrNames`.
2. Walk down one segment at a time instead of evaluating the full path immediately.

Unexpected option value:

1. Inspect `config.<path>` for the final value.
2. Inspect `options.<path>` when type or declaration details matter.

Example:

```nix
nixosConfigurations.<host>.config.services.pipewire.enable
nixosConfigurations.<host>.options.services.pipewire.enable.type.name
```

Derivation or package debugging:

```nix
packages.${builtins.currentSystem}.foo
:p packages.${builtins.currentSystem}.foo.drvAttrs
```

Input or flake output debugging:

```nix
builtins.attrNames inputs
inputs.nixpkgs.outPath
builtins.attrNames overlays
```

## Heuristics

- Prefer `nix repl` over `nix eval` for repeated inspection.
- Inspect attr names before assuming an output shape.
- Keep expressions small while narrowing down an error.
- Reuse the same REPL session until the failing boundary is clear.
- If a path contains special characters, use quoted attrs such as `foo."bar-baz"`.

If a module value is surprising, inspect the realized config first and only inspect `options` when declaration metadata is needed.

## Restrictions

- Do not default to `nix eval` for interactive debugging.
- Do not brute-force deep attr paths without checking parent attrsets first.
- Do not guess host or user keys when `builtins.attrNames` can confirm them.
