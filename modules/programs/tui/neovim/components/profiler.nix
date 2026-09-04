{
  flake.modules.homeManager.neovim.programs.nvf.settings.vim = {
    utility.snacks-nvim.setupOpts.profiler = {
      autocmds = true;

      # keep-sorted start
      filter_fn.default = false;
      filter_mod.default = false;
      # keep-sorted end

      icons = {
        # keep-sorted start
        file = " ";
        require = " ";
        # keep-sorted end
      };
    };

    keymaps = [
      {
        key = "<leader>pp";
        mode = "n";
        action = "<cmd>lua Snacks.profiler.toggle()<CR>";
        desc = "Profiler Toggle";
      }
    ];
  };
}
