{
  flake.modules.homeManager.neovim = {
    programs.nvf.settings.vim.languages.lua = {
      enable = true;

      extraDiagnostics.types = ["selene"];
    };
  };
}
