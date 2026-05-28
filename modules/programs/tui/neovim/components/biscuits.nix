{
  flake.modules.homeManager.neovim = {
    programs.nvf.settings.vim.utility.nvim-biscuits = {
      enable = true;

      setupOpts = {
        # keep-sorted start
        cursor_line_only = true;
        prefix_string = "  ";
        # keep-sorted end
      };
    };
  };
}
