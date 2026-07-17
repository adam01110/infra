---
name: nvf-config
description: Generate, edit, or review Neovim configuration in NVF and Nix form using verified docs instead of guessed APIs. Use for `programs.nvf.settings.*`, `setupOpts`, `keymaps`, language modules, plugin options, `mkLuaInline`, `luaConfigPre` snippets, and translating upstream plugin docs into NVF modules.
---

# NVF Config

Work NVF-first. Treat Neovim config as Nix/NVF, not plain Lua.

Core rule: do not guess NVF options, Neovim APIs, or plugin setup keys. Prefer a small verified Nix snippet over plausible Lua.

Lookup order before editing:

1. Existing repo config.
2. Local NVF option docs/search tools.
3. NVF manual/options reference.
4. NVF module source for the exact option path.
5. Installed Neovim help for built-ins.
6. Plugin docs/source for plugin APIs.
7. Context7, if available.
8. Web or GitHub fallback.
9. Inference only if clearly marked uncertain.

Do not skip directly to writing code from memory.

Repo patterns to preserve:

- `programs.nvf.settings.vim = { ... };`
- modules under `modules/home/tui/neovim/`
- `keymaps = [ { key = ...; mode = ...; action = ...; } ];`
- plugin tables in `setupOpts`
- `lib.generators.mkLuaInline` for Lua functions inside Nix attrs
- `neovim.luaConfigPreSnippets` for early startup logic, autocmds, globals, or larger raw Lua
- nearby helper imports, grouping, list-vs-attrset style, and `keep-sorted` comments
- before adding config, inspect nearby autocmd conventions, language module layout, custom Nix helpers, and existing helper functions
- comments short, local, and only for non-obvious intent

NVF rules:

- Prefer exact `programs.nvf.settings.*` options over raw Lua.
- Confirm option path, type, shape, and whether an NVF wrapper exists.
- Read module source when docs are unclear.
- Keep plugin configuration in `setupOpts` when the NVF module exposes a plugin block.
- Keep Lua valid inside Nix strings and escape `${...}` correctly.
- Use raw Lua only when NVF lacks the feature, cannot express needed callbacks/functions, or the repo already handles that category through `luaConfigPreSnippets`.
- Static keymaps should use NVF keymaps, not `vim.keymap.set()`.
- Do not assume lazy.nvim examples map directly onto NVF options.
- For built-ins, useful help pages include `:help lua`, `api`, `deprecated`, `autocmd-events`, `vim.keymap.set()`, `vim.diagnostic`, `lsp`, and `treesitter`.
- If local docs disagree with memory or upstream examples, local docs win.
- Preserve attribute naming style; prefer explicit nested attrs when matching nearby code; use `let` only when it simplifies the module.

Plugin/API rules:

- Identify the exact plugin repo and version when relevant.
- Check NVF exposure before upstream Lua examples.
- Prefer plugin `doc/*.txt`, README setup docs, examples, `setup()` defaults, then source.
- Use plugin issues/discussions only when official docs and source are missing.
- Do not use fields missing from docs/defaults/source.
- Translate confirmed Lua config into NVF/Nix instead of copying wholesale Lua.

Common shapes:

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

Stop and state uncertainty if the NVF path, option shape, plugin API/version, installed plugin, required unrelated restructure, old-dotfile-only field, or docs/source absence is unclear.

When returning a snippet, include assumptions, target file, code, sources checked, validation command, and uncertainties. Use repo targets when known:

```sh
nix flake check
home-manager build --flake .#<target>
nixos-rebuild build --flake .#<host>
```

Use the repo's actual target names when known. Accuracy is more important than completeness.
