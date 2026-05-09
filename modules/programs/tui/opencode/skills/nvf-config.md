---
name: nvf-config
description: Generate, edit, or review Neovim configuration in NVF and Nix form using verified docs instead of guessed APIs. Use for `programs.nvf.settings.*`, `setupOpts`, `keymaps`, language modules, plugin options, `mkLuaInline`, `luaConfigPre` snippets, and translating upstream plugin docs into NVF modules.
---

# NVF Config Skill

Work NVF-first.

Treat the repo as an NVF and Nix configuration, not a plain Lua config.

When the user asks for a Neovim change, prefer editing `programs.nvf.settings.*` and nearby Nix modules. Only fall back to raw Lua when NVF does not expose the needed option.

## Core rule

Do not guess NVF options, Neovim APIs, or plugin setup keys.

Prefer a small verified Nix snippet over a large plausible Lua snippet.

## Source lookup order

Before writing or changing config, use this order:

1. Existing project config
2. Local NVF option docs or repo-specific option search tools
3. NVF manual and NVF options reference
4. NVF module source for the exact option path
5. Installed Neovim help docs for built-in APIs
6. Plugin repository docs for plugin-specific setup
7. Context7 MCP, if available
8. Web or GitHub fallback
9. Inference only when clearly marked as uncertain

Do not skip directly to writing code from memory.

## Existing config first

Inspect nearby config before adding new code.

Look for:

* NVF option layout
* existing helper functions
* keymap conventions
* autocmd conventions
* custom Nix helpers
* `mkLuaInline` usage
* `luaConfigPre` usage
* language module layout
* repo-specific option search tools

Do not introduce a new style unless necessary.

In this repo, expect patterns like:

* `programs.nvf.settings.vim = { ... };`
* focused modules under `modules/home/tui/neovim/`
* `keymaps = [ { key = ...; mode = ...; action = ...; } ];`
* `setupOpts` for plugin option tables
* `lib.generators.mkLuaInline` for inline Lua functions inside Nix attrsets
* `neovim.luaConfigPreSnippets` for raw Lua that must run before plugin setup

## NVF docs first

Prefer local option search over web examples.

If the repo exposes NVF docs through a local search tool, use that before reading upstream docs.

Good targets to confirm:

* exact `programs.nvf.settings.*` path
* option type
* whether the option is a boolean, attrset, list, or raw Lua string
* whether the plugin already has an NVF wrapper

If a local generated options source exists for NVF, it wins over memory.

## Use NVF docs and module source

For NVF-specific configuration:

1. Find the exact NVF option path.
2. Confirm whether the plugin or feature is already exposed by NVF.
3. Check the option type and example shape.
4. Read the module source when the docs are unclear.
5. Only inject raw Lua for the parts NVF does not model.

Do not assume lazy.nvim examples map directly onto NVF options.

## Use local Neovim docs for core APIs

For built-in Neovim APIs, prefer the installed docs over memory.

Useful help pages:

```vim
:help lua
:help api
:help deprecated
:help autocmd-events
:help vim.keymap.set()
:help vim.diagnostic
:help lsp
:help treesitter
```

If local docs disagree with memory, local docs win.

## Use plugin docs for plugin APIs

For plugin-specific config, identify the exact plugin repository and only do this after checking whether NVF already exposes the needed option.

Prefer sources in this order:

1. `doc/*.txt`
2. README setup section
3. examples shipped in the repo
4. plugin Lua source, especially `setup()` defaults
5. issues or discussions only when official docs are missing

Do not invent setup keys.

If a field is not in the README, help docs, defaults table, or source code, do not use it.

## NVF rules

When working with NVF:

* Prefer NVF options over raw Lua whenever an option exists.
* Use the exact `programs.nvf.settings.*` path used by the repo.
* Match surrounding Nix style before inventing a new layout.
* Keep plugin configuration in `setupOpts` when the module already exposes a plugin block.
* Use `mkLuaInline` for Lua functions embedded inside Nix attrsets.
* Use `neovim.luaConfigPreSnippets` for early startup logic, autocmds, globals, or larger raw Lua blocks that do not belong in a single option value.
* Preserve list-vs-attrset style already used by the repo.
* Keep Lua valid inside Nix strings and escape `${...}` correctly.

Use raw Lua only when at least one of these is true:

* NVF has no option for the feature.
* The option exists but does not expose the needed callback or function body.
* The repo already handles that category of behavior through `luaConfigPreSnippets`.

## Repo patterns

### Simple NVF options

```nix
_: {
  programs.nvf.settings.vim = {
    visuals.nvim-web-devicons.enable = true;
  };
}
```

### Keymaps

Prefer NVF keymaps over raw `vim.keymap.set()` when the mapping is static.

```nix
_: {
  programs.nvf.settings.vim.keymaps = [
    {
      key = "<leader>w";
      mode = "n";
      action = "<cmd>w<cr>";
    }
  ];
}
```

### Plugin setup tables

Prefer `setupOpts` when NVF exposes the plugin and the config is a table.

```nix
{lib, ...}: let
  inherit (lib.generators) mkLuaInline;
in {
  programs.nvf.settings.vim.statusline.lualine.setupOpts = {
    sections.lualine_c = [
      {
        "@1" = "filename";
        fmt = mkLuaInline ''
          function(str)
            return vim.fs.basename(str)
          end
        '';
      }
    ];
  };
}
```

### Early raw Lua snippets

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

## Nix rules

For Nix snippets:

* Preserve attribute naming style.
* Prefer explicit nested attributes when matching surrounding code.
* Use `let` bindings only when they actually simplify the module.
* Preserve helper imports already used nearby, such as `mkLuaInline`.
* Preserve `keep-sorted` comments and existing grouping structure.
* Keep comments short, local, and only for non-obvious intent.

## Plugin API rules

When configuring a plugin:

1. Identify the exact repository.
2. Check whether NVF already exposes the plugin or feature.
3. Check whether the plugin has a help file.
4. Find its current `setup()` signature.
5. Check default options if present.
6. Only use documented or source-confirmed fields.
7. Translate the result into NVF and Nix instead of copying upstream Lua directly.

Bad:

```nix
_: {
  programs.nvf.settings.vim.somePlugin.setupOpts = {
    random_option = true;
  };
}
```

Better:

```text
Unverified: I could not find this NVF option or plugin field in the docs/source.
```

Do not make up options because they sound consistent with other plugins.

## Output format

When giving code, use this format:

```text
Assumption: NVF via Home Manager or NixOS module, Nix config, Neovim >= target version if relevant.

Put this in: modules/home/tui/neovim/<module>.nix
```

Then provide the code:

```nix
_: {
  programs.nvf.settings.vim = {
    # verified NVF options only
  };
}
```

Then provide validation:

```text
Checked against:
- local repo config
- local NVF docs / NVF manual / NVF module source
- plugin docs or Neovim help when needed

Validate with:
home-manager build --flake .#<target>
```

If something is uncertain, say exactly what is uncertain.

## Validation commands

For Nix syntax and evaluation, prefer the repo's normal build command.

```sh
nix flake check
home-manager build --flake .#<target>
nixos-rebuild build --flake .#<host>
```

Use the repo's actual target names when known.

## Hard stop conditions

Stop and state uncertainty when:

* the correct NVF option path cannot be found
* NVF appears to expose the feature, but the option shape is unclear
* the plugin API cannot be found
* the plugin version is unknown and docs differ between versions
* a config field appears only in old dotfiles
* the requested option is not in docs or source
* the snippet depends on a plugin that is not installed
* the change would require restructuring unrelated config

Do not hide uncertainty behind plausible Nix or Lua.

## Final behavior

When asked for an NVF snippet:

1. Inspect existing style.
2. Look for an NVF option before writing raw Lua.
3. Verify APIs and option paths using docs or source.
4. Generate the smallest working Nix snippet.
5. Use raw Lua only where NVF cannot express the change.
6. State assumptions.
7. Provide a validation command.
8. Mention any uncertainty.

Accuracy is more important than completeness.
