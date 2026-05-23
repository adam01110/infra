{
  flake.modules.homeManager.neovim = {config, ...}: {
    programs.nvf.settings.vim = let
      inherit (config.programs.nvf.settings.vim.ui) borderType;
    in {
      # keep-sorted start block=yes newline_separated=yes
      ui = {
        borders = {
          enable = true;
          globalStyle = borderType;

          plugins.which-key = {
            enable = true;
            style = borderType;
          };
        };

        noice = {
          enable = true;

          setupOpts = {
            # Keep using nvim-notify and avoid noice overwrite warnings.
            notify.enabled = false;

            # keep-sorted start block=yes newline_separated=yes
            # Avoid hooking hover and markdown helpers that other plugins replace.
            lsp = {
              hover.enabled = false;

              override = {
                # keep-sorted start
                "vim.lsp.util.convert_input_to_markdown_lines" = false;
                "vim.lsp.util.stylize_markdown" = false;
                # keep-sorted end
              };
            };

            presets.command_palette = true;

            views = {
              # keep-sorted start
              cmdline_popup.border.style = borderType;
              popup.border.style = borderType;
              popupmenu.border.style = borderType;
              # keep-sorted end
            };
            # keep-sorted end
          };
        };
      };

      visuals.nvim-web-devicons.enable = true;
      # keep-sorted end
    };
  };
}
