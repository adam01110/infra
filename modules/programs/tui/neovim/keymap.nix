{
  flake.modules.homeManager.neovim = {
    programs.nvf.settings.vim = {
      keymaps = [
        # keep-sorted start block=yes newline_separated=yes
        {
          key = "<leader>q";
          mode = "n";
          action = "<cmd>q<cr>";
          desc = "Quit window";
        }

        {
          key = "<leader>w";
          mode = "n";
          action = "<cmd>w<cr>";
          desc = "Write file";
        }

        {
          key = "<leader>x";
          mode = "n";
          action = "<cmd>x<cr>";
          desc = "Write and quit";
        }
        # keep-sorted end
      ];
    };
  };
}
