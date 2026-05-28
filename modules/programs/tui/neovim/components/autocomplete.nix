{
  flake.modules.homeManager.neovim = {
    programs.nvf.settings.vim.autocomplete.blink-cmp = {
      enable = true;
      friendly-snippets.enable = true;

      setupOpts = {
        keymap.preset = "default";

        # keep-sorted start
        cmdline.completion.menu.auto_show = true;
        fuzzy.implementation = "prefer_rust_with_warning";
        # keep-sorted end

        # keep-sorted start block=yes newline_separated=yes
        completion = {
          # keep-sorted start
          documentation.auto_show = true;
          ghost_text.enabled = true;
          # keep-sorted end

          keyword.range = "full";
        };

        signature = {
          enabled = true;

          # keep-sorted start
          show_on_insert = true;
          show_on_keyword = true;
          # keep-sorted end
        };

        sourcePlugins = {
          ripgrep.enable = true;
        };

        term = {
          enabled = true;

          completion = {
            # keep-sorted start
            ghost_text.enabled = true;
            menu.auto_show = true;
            # keep-sorted end

            list.selection = {
              # keep-sorted start
              auto_insert = true;
              preselect = true;
              # keep-sorted end
            };
          };
        };
        # keep-sorted end
      };
    };
  };
}
