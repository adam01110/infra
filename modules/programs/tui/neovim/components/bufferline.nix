{
  flake.modules.homeManager.neovim = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit (lib.generators) mkLuaInline;

    colors = config.lib.stylix.colors.withHashtag;
  in {
    # keep-sorted start block=yes newline_separated=yes
    programs.nvf.settings.vim.luaConfigPreSnippets = [
      ''
        function _G.close_lualine_buffer(bufnr, clicks, button, modifiers)
          if button ~= "l" then
            return
          end

          vim.schedule(function()
            if vim.fn.bufexists(bufnr) == 0 then
              return
            end

            -- bdelete errors E516 on listed buffers that are not loaded.
            if vim.fn.bufloaded(bufnr) == 1 then
              vim.cmd(string.format("bdelete %d", bufnr))
            else
              vim.api.nvim_buf_delete(bufnr, {})
            end
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
        section_separators.left = "";
        show_filename_only = true;
        show_modified_status = false;
        # keep-sorted end

        # keep-sorted start
        buffers_color.active = {
          bg = colors.base0D;
          fg = colors.base00;
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
            return string.format('%s%%%d@v:lua.close_lualine_buffer@ %%T', name, context.bufnr)
          end
        '';
      }
    ];
    # keep-sorted end
  };
}
