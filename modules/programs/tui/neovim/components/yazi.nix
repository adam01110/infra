{
  flake.modules.homeManager.neovim = {config, ...}: {
    programs.nvf.settings.vim.utility.yazi-nvim = {
      enable = true;

      setupOpts = {
        # keep-sorted start
        change_neovim_cwd_on_close = true;
        open_for_directories = true;
        open_multiple_tabs = true;
        yazi_floating_window_border = config.programs.nvf.settings.vim.ui.borderType;
        # keep-sorted end
      };
    };
  };
}
