{
  flake.modules.homeManager.neovim = _: {
    programs.nvf.settings.vim = {
      # Enable proper indentation across languages.
      utility = {
        # keep-sorted start
        auto-indent-nvim.enable = true;
        guess-indent-nvim.enable = true;
        # keep-sorted end

        snacks-nvim.setupOpts.indent = {
          enable = true;
          animate.duration.total = 1000;
        };
      };
    };
  };
}
