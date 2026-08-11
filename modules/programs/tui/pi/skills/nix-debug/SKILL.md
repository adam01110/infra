---
name: nix-debug
description: Debug Nix expressions, flakes, modules, options, derivations, and outputs through an interactive nix repl session.
---

# nix debug

need repeated inspection? one `nix repl`; not many `nix eval` calls.

1. choose narrowest useful target.
2. load: `nix repl` then `:lf .`, or `nix repl ./path/to/file.nix`.
3. key unknown? inspect parent with `builtins.attrNames`. never guess host, user, output.
4. walk missing path one segment at time. evaluate small expressions until failing edge known.
5. report exact attr path, value, or error.

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

inspect realized `config` first. need type/declaration metadata? then inspect `options`. special attr name? quote: `foo."bar-baz"`.

interactive debug means `nix repl` default. `nix eval` only when interaction not needed.
