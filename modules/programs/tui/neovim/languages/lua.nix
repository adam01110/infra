{
  flake.modules.homeManager.neovim = _: {
    programs.nvf.settings.vim.languages.lua = {
      enable = true;
      extraDiagnostics.types = ["selene"];
    };
  };
}
