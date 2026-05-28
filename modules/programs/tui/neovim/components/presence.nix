{
  flake.modules.homeManager.neovim = {
    # Discord rich presence via cord.nvim.
    programs.nvf.settings.vim.presence.cord-nvim = {
      enable = true;

      setupOpts = {
        # keep-sorted start block=yes newline_separated=yes
        advanced.discord.reconnect.enabled = true;

        display = {
          # keep-sorted start
          flavor = "accent";
          theme = "minecraft";
          # keep-sorted end
        };

        editor.tooltip = "Editing with Neovim";

        extensions = {
          # keep-sorted start block=yes newline_separated=yes
          diagnostics = {
            # keep-sorted start
            override = true;
            scope = "buffer";
            severity.min = 4;
            # keep-sorted end
          };

          scoped_timestamps = {
            scope = "workspace";
            pause = true;
          };
          # keep-sorted end
        };
        # keep-sorted end
      };
    };
  };
}
