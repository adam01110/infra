{
  flake.modules.homeManager.neovim = _: {
    programs.nvf.settings.vim.utility.snacks-nvim.setupOpts.scroll = {
      enable = true;

      # keep-sorted start
      animate.duration.total = 100;
      animate_repeat.duration.total = 25;
      # keep-sorted end
    };
  };
}
