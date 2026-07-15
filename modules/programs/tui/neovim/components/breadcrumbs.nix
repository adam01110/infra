{
  flake.modules.homeManager.neovim = {
    programs.nvf.settings.vim.ui.breadcrumbs = {
      enable = true;
      source = "dropbar";
    };
  };
}
