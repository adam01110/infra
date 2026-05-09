{
  flake.modules.homeManager.neovim = _: {
    programs.nvf.settings.vim.visuals.dropbar-nvim = {
      enable = true;
    };
  };
}
