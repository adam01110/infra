---
name: nix-debug
description: >-
  Use when diagnosing incorrect, missing, or failing Nix expressions, flakes,
  modules, options, derivations, or outputs, especially when repeated evaluation
  is needed.
license: AGPL-3.0-only
compatibility: Requires Nix with nix repl and access to the target expressions.
metadata:
  author: Adam0
  version: "1.0.0"
  short-description: Diagnose Nix evaluation and module problems
---

# nix debug

This covers evaluation only; load `nix-cli` as well before builds, runs, or
shells.

For repeated inspection, send several expressions to one `nix repl` instead of
many `nix eval` calls. The harness has no terminal, so pass them on stdin:

```python
out = await run("nix", "repl", "--quiet", stdin=":lf .\nbuiltins.attrNames nixosConfigurations\n").text()
```

1. Choose the narrowest useful target.
2. Load it: `:lf .` as the first stdin line, or `nix repl ./path/to/file.nix`.
3. If a key is unknown, list the parent with `builtins.attrNames`. Do not guess
   the host, user, or output.
4. Walk a missing path one segment at a time with small expressions until
   the failing edge is known.
5. Report the exact attr path, value, or error.

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

Inspect the realized `config` first; inspect `options` only when you need type
or declaration metadata. Quote special attr names: `foo."bar-baz"`.

Use a single `nix eval` when only one value is needed.
