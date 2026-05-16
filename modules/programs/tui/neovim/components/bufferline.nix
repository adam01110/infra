{self, ...}: {
  flake.modules.homeManager.neovim = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    colors = config.lib.stylix.colors.withHashtag;
    inherit (lib.generators) mkLuaInline;
  in {
    imports = [self.modules.homeManager.stylixBase];

    # keep-sorted start block=yes newline_separated=yes
    nvf.luaConfigPreSnippets = [
      ''
        function _G.LCB(bufnr, clicks, button, modifiers)
          if button ~= "l" then
            return
          end

          vim.schedule(function()
            vim.cmd(string.format("bdelete %d", bufnr))
          end)
        end
      ''
    ];

    programs.nvf.settings.vim.statusline.lualine.setupOpts.tabline.lualine_c = [
      {
        "@1" = "buffers";
        mode = 0;

        # keep-sorted start
        hide_filename_extension = false;
        show_filename_only = true;
        show_modified_status = false;
        # keep-sorted end

        # keep-sorted start
        buffers_color.active = {
          bg = colors.base0D;
          fg = colors.base00;
          icons_enabled = true;
        };
        # keep-sorted end

        symbols = {
          # keep-sorted start
          alternate_file = "";
          directory = "";
          # keep-sorted end
        };

        max_length = mkLuaInline ''
          function()
            return vim.o.columns + (#vim.fn.getbufinfo({ buflisted = 1 }) * 18)
          end
        '';

        fmt = mkLuaInline ''
          function(name, context)
            return string.format('%s%%%d@v:lua.LCB@ %%T', name, context.bufnr)
          end
        '';
      }
    ];
    # keep-sorted end
  };
}
