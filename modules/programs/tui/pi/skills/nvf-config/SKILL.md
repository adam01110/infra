---
name: nvf-config
description: Generate, edit, or review Neovim configuration in NVF and Nix from verified option and plugin documentation.
---

# nvf config

NVF-first. config is Nix/NVF, not generic Lua. option or API unknown? inspect. never guess.

## lookup order

1. existing repo config.
2. local NVF option docs/search.
3. NVF manual/options.
4. exact NVF module source.
5. installed Neovim help for built-ins.
6. exact plugin docs/source.
7. Context7 when available.
8. web/GitHub fallback.
9. inference only when marked uncertain.

memory conflicts with local docs? local wins.

## preserve repo shape

- `programs.nvf.settings.vim = { ... };`
- modules under `modules/home/tui/neovim/`
- `keymaps = [ { key = ...; mode = ...; action = ...; } ];`
- plugin tables in `setupOpts`
- `lib.generators.mkLuaInline` for Lua functions in Nix attrs
- `neovim.luaConfigPreSnippets` for early logic, autocmds, globals, larger raw Lua
- nearby imports, helpers, grouping, list/attrset style, `keep-sorted` controls
- nearby autocmd conventions, language layout, helper functions: inspect before adding
- comments short, local, non-obvious intent only

## decisions

exact NVF option exists? use it. confirm path, type, shape, wrapper. docs unclear? read module source.

plugin block exposes `setupOpts`? configure there. static mapping? NVF keymaps, not `vim.keymap.set()`. lazy.nvim example? no direct mapping assumption. attribute shape? match nearby style; prefer explicit nested attrs when nearby. `let` only when module gets simpler.

raw Lua allowed only when NVF cannot express feature/callback, or repo already owns category through `luaConfigPreSnippets`. Lua inside Nix must remain valid; escape `${...}`.

plugin API? identify repo and relevant version. inspect in order: NVF exposure, `doc/*.txt`, README setup, examples, `setup()` defaults, source. issues/discussions last. field absent from docs/defaults/source? do not use. translate verified Lua into Nix; do not copy wholesale.

built-in docs useful: `:help lua`, `api`, `deprecated`, `autocmd-events`, `vim.keymap.set()`, `vim.diagnostic`, `lsp`, `treesitter`.

```nix
_: {
  programs.nvf.settings.vim.visuals.nvim-web-devicons.enable = true;
}
```

```nix
_: {
  programs.nvf.settings.vim.keymaps = [
    { key = "<leader>w"; mode = "n"; action = "<cmd>w<cr>"; }
  ];
}
```

```nix
{lib, ...}: let
  inherit (lib.generators) mkLuaInline;
in {
  programs.nvf.settings.vim.statusline.lualine.setupOpts.sections.lualine_c = [
    {
      "@1" = "filename";
      fmt = mkLuaInline ''
        function(str)
          return vim.fs.basename(str)
        end
      '';
    }
  ];
}
```

```nix
_: {
  neovim.luaConfigPreSnippets = [
    ''
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "snacks_dashboard",
        callback = function()
          vim.opt_local.scrolloff = 0
        end,
      })
    ''
  ];
}
```

unclear path, shape, API/version, installed plugin, unrelated restructure, old-dotfile field, or missing evidence? stop; state uncertainty.

return snippet with assumptions, target file, code, sources checked, validation command, uncertainties. known repo target? use exact name:

```sh
nix flake check
home-manager build --flake .#<target>
nixos-rebuild build --flake .#<host>
```

accuracy beats completeness.
