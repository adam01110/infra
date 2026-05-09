{
  flake.modules.homeManager.neovim = _: {
    programs.nvf.settings.vim.languages.rust = {
      enable = true;

      extensions.crates-nvim = {
        enable = true;
        setupOpts = {
        };
      };
    };
  };
}
