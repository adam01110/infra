{
  flake.modules.homeManager.neovim = {
    programs.nvf.settings.vim = {
      # keep-sorted start block=yes newline_separated=yes
      binds = {
        whichKey = {
          enable = true;
          setupOpts.preset = "helix";
        };
      };

      keymaps = [
        {
          key = "<leader>?";
          mode = "n";
          action = "<cmd>Cheatsheet<cr>";
          desc = "Open cheatsheet";
        }
      ];
      # keep-sorted end
    };
  };
}
