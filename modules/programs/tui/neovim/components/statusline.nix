{
  flake.modules.homeManager.neovim = {lib, ...}: let
    inherit (lib.generators) mkLuaInline;
  in {
    programs.nvf.settings.vim.statusline.lualine.setupOpts = {
      # keep-sorted start block=yes newline_separated=yes
      inactive_sections = {
        # keep-sorted start
        lualine_a = [];
        lualine_b = [];
        lualine_c = ["filename"];
        lualine_x = ["location"];
        lualine_y = [];
        lualine_z = [];
        # keep-sorted end
      };

      sections = {
        # keep-sorted start block=yes newline_separated=yes
        lualine_a = ["mode"];

        lualine_b = [
          {
            "@1" = "branch";
            icon = "";
          }

          {
            "@1" = "diff";
            symbols = {
              # keep-sorted start
              added = " ";
              modified = " ";
              removed = " ";
              # keep-sorted end
            };

            source = mkLuaInline ''
              function()
                local gitsigns = vim.b.gitsigns_status_dict
                if gitsigns then
                  return {
                    added = gitsigns.added,
                    modified = gitsigns.changed,
                    removed = gitsigns.removed,
                  }
                end
              end
            '';
          }
        ];

        lualine_c = [
          {
            "@1" = "filetype";
            colored = false;
            icon_only = true;
            icon.align = "left";

            padding = {
              # keep-sorted start
              left = 1;
              right = 0;
              # keep-sorted end
            };

            fmt = mkLuaInline ''
              function(str)
                return vim.trim(str)
              end
            '';
          }

          {
            "@1" = "filename";
            path = 1;
            newfile_status = true;
            padding.left = 0;

            symbols = {
              # keep-sorted start
              modified = "[]";
              newfile = "[New]";
              readonly = "[]";
              unnamed = "[No Name]";
              # keep-sorted end
            };

            fmt = mkLuaInline ''
              function(str)
                local tail = vim.fs.basename(str)
                local parent = vim.fs.basename(vim.fs.dirname(str))

                if parent == "." or parent == "" then
                  return tail
                end

                return '…/' .. parent .. '/' .. tail
              end
            '';
          }
        ];

        lualine_x = [
          {
            "@1" = mkLuaInline ''
              function()
                local buf_ft = vim.bo.filetype
                local excluded_buf_ft = { toggleterm = true, NvimTree = true, ["neo-tree"] = true, TelescopePrompt = true }

                if excluded_buf_ft[buf_ft] then
                  return ""
                end

                local bufnr = vim.api.nvim_get_current_buf()
                local clients = vim.lsp.get_clients({ bufnr = bufnr })

                if vim.tbl_isempty(clients) then
                  return "No Active LSP"
                end

                local active_clients = {}
                for _, client in ipairs(clients) do
                  table.insert(active_clients, client.name)
                end

                return table.concat(active_clients, ", ")
              end
            '';
            icon = "";
          }

          {
            "@1" = "diagnostics";
            always_visible = false;

            # keep-sorted start block=yes newline_separated=yes
            diagnostics_color = {
              # keep-sorted start
              error.fg = "red";
              info.fg = "cyan";
              warn.fg = "yellow";
              # keep-sorted end
            };

            sources = [
              # keep-sorted start
              "coc"
              "nvim_diagnostic"
              "nvim_lsp"
              "vim_lsp"
              # keep-sorted end
            ];

            symbols = {
              # keep-sorted start
              error = "󰅙  ";
              hint = "󰌵 ";
              info = "  ";
              warn = "  ";
              # keep-sorted end
            };
            # keep-sorted end
          }
        ];

        lualine_y = [
          {
            "@1" = "encoding";
            padding = {
              # keep-sorted start
              left = 1;
              right = 0;
              # keep-sorted end
            };
          }

          {
            "@1" = "progress";
          }
        ];

        lualine_z = [
          "location"
          {
            "@1" = "fileformat";
            color.fg = "black";
          }
        ];
        # keep-sorted end
      };
      # keep-sorted end
    };
  };
}
