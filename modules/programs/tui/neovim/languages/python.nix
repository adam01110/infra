{
  flake.modules.homeManager.neovim = {
    programs.nvf.settings.vim.languages.python = {
      enable = true;
      format.type = ["ruff"];
      lsp.servers = ["ty"];
    };
  };
}
