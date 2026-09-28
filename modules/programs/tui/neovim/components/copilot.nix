{
  flake.modules.homeManager.neovim = {
    config,
    pkgs,
    ...
  }: let
    colors = config.lib.stylix.colors.withHashtag;
  in {
    programs.nvf.settings.vim = {
      luaConfigPreSnippets = [
        "vim.g.copilot_nes_debounce = 500"
      ];

      highlight = {
        # keep-sorted start
        CopilotAnnotation.fg = colors.base03;
        CopilotSuggestion.fg = colors.base04;
        # keep-sorted end
      };

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

      lazy.plugins = {
        copilot-lsp = {
          package = pkgs.vimPlugins.copilot-lsp;

          event = {
            event = "User";
            pattern = "LazyFile";
          };
        };

        copilot-lualine = {package = pkgs.vimPlugins.copilot-lualine;};
      };
    };
  };
}
