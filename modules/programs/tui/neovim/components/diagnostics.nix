{
  flake.modules.homeManager.neovim = {
    programs.nvf.settings.vim = {
      lsp.trouble.enable = true;
      utility.snacks-nvim.setupOpts.statuscolumn.enable = true;
    };
  };
}
