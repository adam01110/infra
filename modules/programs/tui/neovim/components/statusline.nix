{
  flake.modules.homeManager.neovim = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib.generators) mkLuaInline;

    colors = config.lib.stylix.colors.withHashtag;
  in {
    # jj-starship renders the jj statusline component.
    programs.nvf.settings.vim = {
      extraPackages = [pkgs.jj-starship];

      luaConfigPreSnippets = [
        ''
          local function jj_statusline(palette)
            if vim.fn.executable("jj-starship") ~= 1 then
              return {
                component = function()
                  return ""
                end,
                is_in_workspace = function()
                  return false
                end,
              }
            end

            -- ANSI codes emitted by jj-starship, mapped to palette colors.
            local ansi_colors = {
              ["31"] = { name = "status", color = palette.error },
              ["32"] = { name = "bookmark", color = palette.success },
              ["33"] = { name = "status_empty", color = palette.warning },
              ["34"] = { name = "symbol", color = palette.info },
              ["35"] = { name = "change", color = palette.accent },
              ["90"] = { name = "rest", color = palette.muted },
              ["95"] = { name = "prefix", color = palette.accent },
            }

            local state = { buffer = -1, root = nil, text = "" }
            local job = nil
            local watcher = nil
            local load

            local function workspace_root(bufnr)
              local source = vim.api.nvim_buf_get_name(bufnr) ~= "" and bufnr or vim.fn.getcwd()

              return vim.fs.root(source, ".jj")
            end

            local function starship(buffer, root)
              job = vim.system({ "jj-starship", "--cwd", root }, { text = true }, function(completed)
                job = nil

                if completed.code ~= 0 or state.buffer ~= buffer then
                  return
                end

                local text = vim.trim(((completed.stdout or ""):gsub("^on ", "")))

                vim.schedule(function()
                  state.text = text

                  require("lualine").refresh()
                end)
              end)
            end

            local function watch(root)
              if watcher then
                watcher:stop()
                watcher = nil
              end

              if not root then
                return
              end

              -- jj rewrites op heads on every operation, so watch them for changes.
              local op_heads = vim.fs.joinpath(root, ".jj", "repo", "op_heads", "heads")

              if vim.uv.fs_stat(op_heads) then
                watcher = assert(vim.uv.new_fs_event())
                watcher:start(op_heads, {}, vim.schedule_wrap(load))
              end
            end

            load = function()
              local buffer = vim.api.nvim_get_current_buf()
              local root = workspace_root(buffer)

              if job then
                job:kill(15)
                job = nil
              end

              if root ~= state.root then
                watch(root)
              end

              state.buffer, state.root, state.text = buffer, root, ""

              if root then
                starship(buffer, root)
              end
            end

            local function highlight(self, code)
              local ansi_style = ansi_colors[code]

              if not ansi_style then
                return ""
              end

              self.highlights = self.highlights or {}

              if not self.highlights[code] then
                self.highlights[code] = self:create_hl({ fg = ansi_style.color }, "jj_" .. ansi_style.name)
              end

              return self:format_hl(self.highlights[code])
            end

            local function parse(text)
              local tokens = {}
              local position = 1

              while true do
                local start_index, end_index, code = text:find("\27%[(%d+)m", position)

                if not start_index then
                  tokens[#tokens + 1] = { text = text:sub(position) }

                  break
                end

                if start_index > position then
                  tokens[#tokens + 1] = { text = text:sub(position, start_index - 1) }
                end

                tokens[#tokens + 1] = { code = code }
                position = end_index + 1
              end

              return tokens
            end

            local function render(self, tokens)
              local parts = {}

              for _, token in ipairs(tokens) do
                parts[#parts + 1] = token.code and highlight(self, token.code) or token.text or ""
              end

              return table.concat(parts)
            end

            local function component(self)
              if state.buffer ~= vim.api.nvim_get_current_buf() or state.text == "" then
                return ""
              end

              return render(self, parse(state.text))
            end

            local function is_in_workspace()
              return state.buffer == vim.api.nvim_get_current_buf() and state.root ~= nil
            end

            vim.api.nvim_create_autocmd({ "UIEnter", "BufEnter", "BufWritePost", "FocusGained" }, {
              group = vim.api.nvim_create_augroup("jj-lualine", {}),
              callback = load,
            })

            load()

            return { component = component, is_in_workspace = is_in_workspace }
          end

          _G.jj_statusline = jj_statusline({
            accent = "${colors.base0E}",
            error = "${colors.base08}",
            info = "${colors.base0C}",
            muted = "${colors.base04}",
            success = "${colors.base0B}",
            warning = "${colors.base0A}",
          })
        ''
      ];

      statusline.lualine.setupOpts = {
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

        options = {
          component_separators = {
            # keep-sorted start
            left = "";
            right = "";
            # keep-sorted end
          };

          section_separators = {
            # keep-sorted start
            left = "";
            right = "";
            # keep-sorted end
          };
        };

        sections = {
          # keep-sorted start block=yes newline_separated=yes
          lualine_a = ["mode"];

          lualine_b = [
            {
              "@1" = "branch";
              icon = "";
              cond = mkLuaInline ''
                function()
                  return not _G.jj_statusline.is_in_workspace()
                end
              '';
            }

            {
              "@1" = mkLuaInline ''
                function(self)
                  return _G.jj_statusline.component(self)
                end
              '';
              cond = mkLuaInline ''
                function()
                  return _G.jj_statusline.is_in_workspace()
                end
              '';
            }

            "diff"
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
  };
}
