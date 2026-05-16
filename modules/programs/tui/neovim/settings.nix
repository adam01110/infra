{self, ...}: {
  flake.modules.homeManager.neovim = {config, ...}: let
    colors = config.lib.stylix.colors.withHashtag;
  in {
    imports = [self.modules.homeManager.stylixBase];

    programs.nvf.settings.vim = {
      searchCase = "smart";

      options = {
        # keep-sorted start
        cursorline = true;
        cursorlineopt = "both";
        mouse = "a";
        wrap = false;
        # keep-sorted end
      };

      # keep-sorted start block=yes newline_separated=yes
      clipboard = {
        enable = true;
        providers.wl-copy.enable = true;
        registers = "unnamedplus";
      };

      highlight.CursorLineNr.fg = colors.base0E;

      lsp = {
        enable = true;
        formatOnSave = true;

        # Support embedded code blocks in mixed-language buffers.
        otter-nvim = {
          enable = true;
          setupOpts.handle_leading_whitespace = true;
        };
      };
      # keep-sorted end
    };
  };
}
