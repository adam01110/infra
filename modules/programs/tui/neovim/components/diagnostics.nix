{
  flake.modules.homeManager.neovim = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit (lib.generators) mkLuaInline;
    inherit (lib.self) blendHex;

    colors = config.lib.stylix.colors.withHashtag;
  in {
    programs.nvf.settings.vim = {
      utility.snacks-nvim.setupOpts.statuscolumn.enable = true;

      diagnostics = {
        enable = true;
        config = {
          virtual_lines = false;

          signs.text = mkLuaInline ''
            {
              [vim.diagnostic.severity.ERROR] = "󰅙 ",
              [vim.diagnostic.severity.WARN] = "󰀦 ",
              [vim.diagnostic.severity.INFO] = "󰋼 ",
              [vim.diagnostic.severity.HINT] = "󰌵 ",
            }
          '';

          virtual_text = {
            prefix = mkLuaInline ''
              function(diagnostic, index, total)
                if index ~= total then
                  return ""
                end

                local icons = {
                  [vim.diagnostic.severity.ERROR] = "󰅙",
                  [vim.diagnostic.severity.WARN] = "󰀦",
                  [vim.diagnostic.severity.INFO] = "󰋼",
                  [vim.diagnostic.severity.HINT] = "󰌵",
                }
                return icons[diagnostic.severity]
              end
            '';
            source = false;
            spacing = 2;
          };
        };
      };

      highlight = {
        # keep-sorted start block=yes newline_separated=yes
        DiagnosticSignWarn.fg = colors.base0A;

        DiagnosticUnderlineWarn = {
          # keep-sorted start
          sp = colors.base0A;
          undercurl = true;
          # keep-sorted end
        };

        DiagnosticVirtualTextError = {
          # keep-sorted start
          bg = blendHex 15 colors.base00 colors.base08;
          fg = colors.base08;
          # keep-sorted end
        };

        DiagnosticVirtualTextHint = {
          # keep-sorted start
          bg = blendHex 15 colors.base00 colors.base0C;
          fg = colors.base0C;
          # keep-sorted end
        };

        DiagnosticVirtualTextInfo = {
          # keep-sorted start
          bg = blendHex 15 colors.base00 colors.base0C;
          fg = colors.base0C;
          # keep-sorted end
        };

        DiagnosticVirtualTextWarn = {
          # keep-sorted start
          bg = blendHex 15 colors.base00 colors.base0A;
          fg = colors.base0A;
          # keep-sorted end
        };
        # keep-sorted end
      };

      keymaps = [
        {
          key = "<leader>tv";
          mode = "n";
          action = "<cmd>lua local config = vim.diagnostic.config(); if config.virtual_text then _G.saved_diagnostic_virtual_text = config.virtual_text; vim.diagnostic.config({ virtual_text = false }) else vim.diagnostic.config({ virtual_text = _G.saved_diagnostic_virtual_text or true }) end<cr>";
          desc = "Toggle inline diagnostics";
        }
      ];
    };
  };
}
