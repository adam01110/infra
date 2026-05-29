---
name: nix-debug
description: Use this skill to debug Nix expressions, flake outputs, modules, and option values with `nix repl`. Prefer it when investigating evaluation errors, missing attributes, unexpected option values, derivation inputs, or output structure. Use `nix repl` instead of `nix eval` for inspection because the interactive REPL is faster for repeated queries.
---

## Nix Debug

Prefer one `nix repl` session over many `nix eval` calls.

Workflow:

1. Start from the narrowest useful target.
2. Load the flake/expression: `nix repl`, then `:lf .`, or `nix repl ./path/to/file.nix`.
3. Inspect parent attrsets with `builtins.attrNames` before deep paths.
4. Evaluate small subexpressions until the failing edge is clear.
5. Report the exact attr path, value, or error.

Useful probes:

```nix
builtins.attrNames inputs
builtins.attrNames packages
builtins.attrNames nixosConfigurations
builtins.attrNames homeConfigurations
nixosConfigurations.<host>.config.<path>
nixosConfigurations.<host>.options.<path>
inputs.nixpkgs.outPath
builtins.attrNames overlays
:p packages.${builtins.currentSystem}.foo.drvAttrs
```

Rules:

- Do not default to `nix eval` for interactive debugging.
- Do not guess host/user/output keys when `builtins.attrNames` can confirm them.
- Walk missing attrs one segment at a time.
- Inspect realized `config` first; inspect `options` only for type/declaration metadata.
- Use quoted attrs for special names: `foo."bar-baz"`.
