{
  flake.modules.homeManager.neovim = {
    programs.nvf.settings.vim.languages.csharp = {
      enable = true;
      format.type = ["csharpier"];
    };
  };
}
