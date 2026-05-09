{
  flake.modules.homeManager.neovim = _: {
    programs.nvf.settings.vim.binds.hardtime-nvim = {
      enable = true;

      setupOpts = {
        # keep-sorted start
        disable_mouse = false;
        max_count = 4;
        restriction_mode = "hint";
        showmode = false;
        # keep-sorted end
      };
    };
  };
}
