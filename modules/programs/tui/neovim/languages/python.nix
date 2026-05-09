{
  flake.modules.homeManager.neovim = _: {
    programs.nvf.settings.vim.languages.python = {
      enable = true;
      format.type = ["ruff"];
      lsp.servers = ["ty"];
    };
  };
}
