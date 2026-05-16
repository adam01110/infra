{
  flake.modules.homeManager.neovim = _: {
    programs.nvf.settings.vim.languages.docker = {
      enable = true;
      extraDiagnostics.enable = true;
    };
  };
}
