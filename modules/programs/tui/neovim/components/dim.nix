{
  flake.modules.homeManager.neovim.programs.nvf.settings.vim = {
    utility.snacks-nvim.setupOpts.dim = {
      enable = true;
      scope.min_size = 8;
    };

    keymaps = [
      {
        key = "<leader>td";
        mode = "n";
        action = "<cmd>lua if Snacks.dim.enabled then Snacks.dim.disable() else Snacks.dim.enable() end<CR>";
        desc = "Dim Toggle";
      }
    ];
  };
}
