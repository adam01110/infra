{
  flake.modules.homeManager.neovim = {
    # keep-sorted start
    osConfig,
    pkgs,
    # keep-sorted end
    ...
  }: let
    colors = osConfig.lib.stylix.colors.withHashtag;
  in {
    nvf.luaConfigPreSnippets = [
      # Install Telescope as the global vim.ui.select provider after UI startup.
      ''
        vim.api.nvim_create_autocmd("User", {
          pattern = "DeferredUIEnter",
          once = true,
          callback = function()
            pcall(function()
              require("telescope").load_extension("ui-select")
            end)
          end,
        })
      ''
    ];

    programs.nvf.settings.vim = {
      # keep-sorted start block=yes newline_separated=yes
      highlight = {
        # keep-sorted start
        TelescopeBorder.fg = colors.base04;
        TelescopeNormal.bg = colors.base00;
        TelescopePreviewBorder.fg = colors.base04;
        TelescopePreviewNormal.bg = colors.base00;
        TelescopePromptBorder.fg = colors.base04;
        TelescopePromptCounter.bg = colors.base00;
        TelescopePromptNormal.bg = colors.base00;
        TelescopePromptPrefix.bg = colors.base00;
        TelescopeResultsBorder.fg = colors.base04;
        TelescopeResultsNormal.bg = colors.base00;
        TelescopeResultsTitle.bg = colors.base0E;
        TelescopeResultsTitle.fg = colors.base00;
        # keep-sorted end
      };

      keymaps = [
        {
          key = "<leader>fn";
          mode = "n";
          action = "<cmd>Telescope notify<cr>";
          desc = "Open notifications";
        }
      ];

      lazy.plugins."telescope-all-recent.nvim" = {
        package = pkgs.telescope-all-recent-nvim;
        setupModule = "telescope-all-recent";

        event = {
          event = "User";
          pattern = "DeferredUIEnter";
        };
      };

      # Keep Telescope borders in explicit single-line style.
      telescope = {
        enable = true;

        extensions = [
          # keep-sorted start block=yes newline_separated=yes
          {
            name = "fzf";
            packages = [pkgs.vimPlugins.telescope-fzf-native-nvim];
          }

          {
            name = "ui-select";
            packages = [pkgs.vimPlugins.telescope-ui-select-nvim];
          }
          # keep-sorted end
        ];

        setupOpts.defaults = {
          # keep-sorted start
          border = true;
          borderchars = ["─" "│" "─" "│" "┌" "┐" "┘" "└"];
          color_devicons = true;
          layout_config.horizontal.prompt_position = "top";
          selection_caret = "➜ ";
          sorting_strategy = "ascending";
          # keep-sorted end
        };
      };
      # keep-sorted end
    };
  };
}
