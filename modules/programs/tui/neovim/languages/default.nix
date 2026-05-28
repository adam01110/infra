{
  flake.modules.homeManager.neovim = {
    programs.nvf.settings.vim.languages = {
      # keep-sorted start
      enableExtraDiagnostics = true;
      enableFormat = true;
      enableTreesitter = true;
      # keep-sorted end
    };
  };
}
