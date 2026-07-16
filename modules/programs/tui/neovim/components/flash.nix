{
  flake.modules.homeManager.neovim = {lib, ...}: let
    inherit (lib.generators) mkLuaInline;

    telescopeFlash = mkLuaInline ''
      function(prompt_bufnr)
        require("lz.n").trigger_load("flash-nvim")
        require("flash").jump({
          pattern = "^",
          label = { after = { 0, 0 } },
          search = {
            mode = "search",
            exclude = {
              function(win)
                return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
              end,
            },
          },
          action = function(match)
            local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
            picker:set_selection(match.pos[1] - 1)
          end,
        })
      end
    '';
  in {
    programs.nvf.settings.vim = {
      keymaps = [
        {
          key = "<leader>jd";
          mode = "n";
          action = "<cmd>lua _G.flash_diagnostics()<cr>";
          desc = "Show diagnostics at Flash target";
        }
      ];

      luaConfigPreSnippets = [
        ''
          function _G.flash_diagnostics()
            require("lz.n").trigger_load("flash-nvim")
            require("flash").jump({
              action = function(match, state)
                vim.api.nvim_win_call(match.win, function()
                  vim.api.nvim_win_set_cursor(match.win, match.pos)
                  vim.diagnostic.open_float()
                end)
                state:restore()
              end,
            })
          end
        ''
      ];

      telescope.setupOpts.defaults.mappings = {
        i."<C-s>" = telescopeFlash;
        n.s = telescopeFlash;
      };

      utility.motion.flash-nvim.enable = true;
    };
  };
}
