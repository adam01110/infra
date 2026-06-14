{
  flake.modules.homeManager.neovim = {
    programs.nvf.settings.vim.visuals.satellite-nvim = {
      enable = true;
      setupOpts = {
        # keep-sorted start block=yes newline_separated=yes
        current_only = true;

        gitsigns.signs = {
          # keep-sorted start
          add = "▎";
          change = "▎";
          delete = "";
          # keep-sorted end
        };
        # keep-sorted end
      };
    };
  };
}
