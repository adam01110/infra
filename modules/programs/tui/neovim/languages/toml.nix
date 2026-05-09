{
  flake.modules.homeManager.neovim = _: {
    programs.nvf.settings.vim.languages.toml = {
      enable = true;
      format.type = ["tombi"];
    };
  };
}
