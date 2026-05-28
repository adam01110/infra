{
  flake.modules.homeManager.neovim = {
    programs.nvf.settings.vim.languages.docker = {
      enable = true;
      extraDiagnostics.enable = true;
    };
  };
}
