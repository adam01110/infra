{
  flake.modules.homeManager.neovim = {pkgs, ...}: {
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

      lazy.plugins."noCheatSheet.nvim" = {
        cmd = "Cheatsheet";
        package = pkgs.nocheatsheet-nvim;
        setupModule = "nocheatsheet";
      };
      # keep-sorted end
    };
  };
}
