{
  flake.modules.homeManager.neovim = {
    programs.nvf.settings.vim.languages.toml = {
      enable = true;
      format.type = ["tombi"];
    };
  };
}
