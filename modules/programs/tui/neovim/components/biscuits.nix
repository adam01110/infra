{
  flake.modules.homeManager.neovim = _: {
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
