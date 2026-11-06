{
  flake.modules.homeManager.neovim.programs.nvf.settings.vim.languages.csharp = {
    enable = true;
    format.enable = false;
    lsp.servers = ["roslyn-ls"];
  };
}
