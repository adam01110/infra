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
    programs.nvf.settings.vim.luaConfigPreSnippets = [
      ''
        _G.jj_diff_cache = {}

        local function jj_root(bufnr)
          if vim.bo[bufnr].buftype ~= "" then
            return nil
          end

          local path = vim.api.nvim_buf_get_name(bufnr)
          if path == "" then
            return nil
          end

          return vim.fs.root(path, ".jj")
        end

        local function parse_jj_diff(output)
          local status = { added = 0, modified = 0, removed = 0 }
          local additions = 0
          local deletions = 0
          local in_hunk = false

          local function flush_changes()
            local modified = math.min(additions, deletions)
            status.added = status.added + additions - modified
            status.modified = status.modified + modified
            status.removed = status.removed + deletions - modified
            additions = 0
            deletions = 0
          end

          for line in (output .. "\n"):gmatch("(.-)\n") do
            if line:sub(1, 10) == "diff --git" then
              flush_changes()
              in_hunk = false
            elseif line:sub(1, 2) == "@@" then
              flush_changes()
              in_hunk = true
            elseif in_hunk and line:sub(1, 1) == "+" then
              additions = additions + 1
            elseif in_hunk and line:sub(1, 1) == "-" then
              deletions = deletions + 1
            elseif in_hunk then
              flush_changes()
            end
          end

          flush_changes()
          return status
        end

        local function update_jj_diff()
          local root = jj_root(vim.api.nvim_get_current_buf())
          if not root or vim.fn.executable("jj") ~= 1 then
            return
          end

          vim.system(
            { "jj", "--no-pager", "--color", "never", "diff", "--git" },
            { cwd = root, text = true },
            function(result)
              if result.code ~= 0 then
                return
              end

              local status = parse_jj_diff(result.stdout or "")
              vim.schedule(function()
                _G.jj_diff_cache[root] = status
                pcall(require("lualine").refresh, { place = { "statusline" } })
              end)
            end
          )
        end

        vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "FocusGained" }, {
          callback = update_jj_diff,
        })
      ''
    ];

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
                local bufnr = vim.api.nvim_get_current_buf()
                local path = vim.api.nvim_buf_get_name(bufnr)
                local root = path ~= "" and vim.fs.root(path, ".jj") or nil

                return root and _G.jj_diff_cache[root] or nil
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

            # keep-sorted start block=yes newline_separated=yes
            diagnostics_color = {
              # keep-sorted start
              error.fg = colors.base08;
              hint.fg = colors.base0B;
              info.fg = colors.base0C;
              warn.fg = colors.base0A;
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
              error = "󰅙 ";
              hint = "󰌵 ";
              info = " ";
              warn = " ";
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
