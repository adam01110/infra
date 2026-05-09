{
  flake.modules.homeManager.neovim = _: {
    programs.nvf.settings.vim.ui.colorizer = {
      enable = true;

      setupOpts = {
        filetypes = {
          "*" = {};
          "!snacks_dashboard" = {};
        };

        "options" = {
          always_update = true;

          # keep-sorted start block=yes newline_separated=yes
          display = {
            mode = "virtualtext";
            virtualtext = {
              char = "";
              position = "before";
            };
          };

          parsers = {
            # keep-sorted start
            css = true;
            css_color.enable = true;
            css_fn = true;
            css_var.enable = true;
            css_var_rgb.enable = true;
            hsl.enable = true;
            hsluv.enable = true;
            hwb.enable = true;
            lab.enable = true;
            lch.enable = true;
            oklch.enable = true;
            rgb.enable = true;
            sass.enable = true;
            xcolor.enable = true;
            xterm.enable = true;
            # keep-sorted end

            # keep-sorted start block=yes newline_separated=yes
            hex = {
              rrggbbaa = true;
              hash_aarrggbb = true;
              aarrggbb = true;
              no_hash = true;
            };

            tailwind = {
              enable = true;
              lsp.enable = true;

              update_names = true;
            };
            # keep-sorted end
          };
          # keep-sorted end
        };
      };
    };
  };
}
