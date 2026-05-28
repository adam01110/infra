{
  flake.modules.homeManager.neovim = {
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
