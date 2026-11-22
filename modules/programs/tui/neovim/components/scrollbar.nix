{
  flake.aspects.neovim.homeManager.programs.nvf.settings.vim.visuals.satellite-nvim = {
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

      # Blending against the cleared Normal background mixes with black, not gruvbox.
      winblend = 0;
      # keep-sorted end
    };
  };
}
