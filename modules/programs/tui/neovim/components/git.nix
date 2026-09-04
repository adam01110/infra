{
  flake.modules.homeManager.neovim.programs.nvf.settings.vim.git.gitsigns = {
    enable = true;

    setupOpts = {
      # keep-sorted start block=yes newline_separated=yes
      signs = {
        # keep-sorted start
        add.text = "▎";
        change.text = "▎";
        changedelete.text = "▎";
        delete.text = "";
        topdelete.text = "";
        untracked.text = "┆";
        # keep-sorted end
      };

      signs_staged = {
        # keep-sorted start
        add.text = "▎";
        change.text = "▎";
        changedelete.text = "▎";
        delete.text = "";
        topdelete.text = "";
        untracked.text = "┆";
        # keep-sorted end
      };
      # keep-sorted end
    };
  };
}
