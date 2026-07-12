{
  flake.modules.homeManager.neovim = {
    programs.nvf.settings.vim.languages.rust = {
      enable = true;

      extensions.crates-nvim = {
        enable = true;

        setupOpts.popup = {
          autofocus = true;
          show_version_date = true;
        };
      };
    };
  };
}
