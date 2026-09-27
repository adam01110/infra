{
  flake.modules.homeManager.neovim = {pkgs, ...}: {
    programs.nvf.settings.vim = {
      luaConfigPreSnippets = [
        "vim.g.copilot_nes_debounce = 500"
      ];

      assistant.copilot = {
        enable = true;

        setupOpts = {
          # Ghost text suggestions fire without manual trigger.
          suggestion.auto_trigger = true;

          nes = {
            enabled = true;

            keymap = {
              # keep-sorted start
              accept = false;
              accept_and_goto = "<leader>p";
              dismiss = "<Esc>";
              # keep-sorted end
            };
          };
        };
      };

      lazy.plugins."copilot-lsp" = {
        package = pkgs.vimPlugins.copilot-lsp;

        event = {
          event = "User";
          pattern = "LazyFile";
        };
      };

      lazy.plugins."copilot-lualine" = {
        package = pkgs.vimPlugins.copilot-lualine;
      };
    };
  };
}
