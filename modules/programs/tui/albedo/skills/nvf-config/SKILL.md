---
name: nvf-config
description: >-
  Use when creating, editing, reviewing, or troubleshooting Neovim configuration
  written with NVF and Nix.
license: AGPL-3.0-only
compatibility: Requires Nix, NVF sources or docs, and the target configuration.
metadata:
  author: Adam0
  version: "1.0.0"
  short-description: Configure Neovim through NVF and Nix
allowed-tools: read grep find bash web_search fetch_content
---

# nvf config

Work NVF-first: the config is Nix/NVF, not generic Lua. When an option or API
is unknown, inspect sources instead of guessing.

## Lookup order

1. Existing repo config.
2. Local NVF option docs/search.
3. NVF manual/options.
4. Exact NVF module source.
5. Installed Neovim help for built-ins.
6. Exact plugin docs/source.
7. Context7 when available.
8. Web/GitHub fallback.
9. Inference, only when marked uncertain.

If memory conflicts with local docs, local docs win.

## Preserve repo shape

- `programs.nvf.settings.vim = { ... };`
- Modules under `modules/programs/tui/neovim/`.
- `keymaps = [ { key = ...; mode = ...; action = ...; } ];`
- Plugin tables in `setupOpts`.
- `lib.generators.mkLuaInline` for Lua functions in Nix attrs.
- `neovim.luaConfigPreSnippets` for early logic, autocmds, globals, and larger
  raw Lua.
- Nearby imports, helpers, grouping, list/attrset style, and `keep-sorted`
  controls.
- Inspect nearby autocmd conventions, language layout, and helper functions
  before adding new ones.
- Comments short, local, and only for non-obvious intent.

## Decisions

- If an exact NVF option exists, use it. Confirm its path, type, shape, and
  wrapper; read the module source when docs are unclear.
- If the plugin block exposes `setupOpts`, configure it there.
- Use NVF keymaps for static mappings, not `vim.keymap.set()`.
- Do not assume a lazy.nvim example maps directly to NVF.
- Match nearby attribute shape; prefer explicit nested attrs when nearby code
  uses them. Add `let` only when it makes the module simpler.
- Use raw Lua only when NVF cannot express the feature or callback, or the repo
  already owns that category through `luaConfigPreSnippets`. Lua inside Nix
  must stay valid; escape `${...}`.

For a plugin API, identify the repo and relevant version, then inspect in
order: NVF exposure, `doc/*.txt`, README setup, examples, `setup()` defaults,
source. Check issues/discussions last. Do not use a field absent from docs,
defaults, and source. Translate verified Lua into Nix rather than copying it
wholesale.

Useful built-in docs: `:help lua`, `api`, `deprecated`, `autocmd-events`,
`vim.keymap.set()`, `vim.diagnostic`, `lsp`, `treesitter`.

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

If the path, shape, API/version, installed plugin, an unrelated restructure, an
old-dotfile field, or evidence is unclear or missing, stop and state the
uncertainty.

Return the snippet with assumptions, target file, code, sources checked,
validation command, and uncertainties. Use the exact name when the repo target
is known:

```sh
nix flake check
nh home build .
nh os build . -H <host>
```

Build-only runs are fine without asking; follow the `nix-cli` skill for
anything that activates.

Accuracy beats completeness.
