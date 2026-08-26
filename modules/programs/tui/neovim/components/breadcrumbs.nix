{
  flake.modules.homeManager.neovim = {
    programs.nvf.settings.vim = {
      # keep-sorted start block=yes newline_separated=yes
      keymaps = [
        {
          key = "<leader>nv";
          mode = "n";
          action = "<cmd>Navbuddy<cr>";
          desc = "Open Navbuddy";
        }
      ];

      statusline.lualine.integrations.breadcrumbs = {
        location = "winbar";
        navbuddy.enable = true;
      };
      # keep-sorted end
    };
  };
}
