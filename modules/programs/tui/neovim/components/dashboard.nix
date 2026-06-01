{
  flake.modules.homeManager.neovim = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;
    inherit (lib.generators) mkLuaInline;

    colors = config.lib.stylix.colors.withHashtag;

    dashboardGhNotify = pkgs.writeShellApplication {
      name = "dashboard-gh-notify";
      runtimeInputs = [pkgs.coreutils];
      text = ''
        GH_TOKEN="$(cat "${config.sops.secrets.github_token.path}")"
        export GH_TOKEN
        exec "${getExe pkgs.gh-notify}" "$@"
      '';
    };
  in {
    # keep-sorted start block=yes newline_separated=yes
    # Capture dashboard metrics once so the footer can read cached values.
    programs.nvf.settings.vim.luaConfigPreSnippets = [
      # Cache startup timing and plugin counts after the UI attaches.
      ''
        vim.g.snacks_dashboard_start_ns = vim.uv.hrtime()
          vim.api.nvim_create_autocmd("UIEnter", {
            once = true,
            callback = function()
              local start_plugins = vim.fn.globpath(vim.o.packpath, "pack/*/start/*", 0, 1)
              local opt_plugins = vim.fn.globpath(vim.o.packpath, "pack/*/opt/*", 0, 1)
              local loaded = 0

              for _, path in ipairs(vim.api.nvim_list_runtime_paths()) do
                if path:find("/pack/", 1, true)
                  and (path:find("/start/", 1, true) or path:find("/opt/", 1, true))
                then
                  loaded = loaded + 1
                end
              end

            vim.g.snacks_dashboard_metrics = {
              loaded = loaded,
              ms = (vim.uv.hrtime() - vim.g.snacks_dashboard_start_ns) / 1e6,
              total = #start_plugins + #opt_plugins,
            }
          end,
        })
      ''

      # Keep dashboard labels and file/project icons on the requested colors.
      ''
        local function apply_dashboard_highlights()
          vim.api.nvim_set_hl(0, "SnacksDashboardDesc", { link = "Function" })
          vim.api.nvim_set_hl(0, "SnacksDashboardFileIcon", { fg = "${colors.base0E}" })
          vim.api.nvim_set_hl(0, "SnacksDashboardDirIcon", { fg = "${colors.base0E}" })
        end

        apply_dashboard_highlights()

        vim.api.nvim_create_autocmd("ColorScheme", {
          callback = apply_dashboard_highlights,
        })
      ''

      # Adjust local UI behavior while the Snacks dashboard buffer is active.
      ''
        local function configure_dashboard_ui()
          if vim.bo.filetype ~= "snacks_dashboard" then
            return
          end

          vim.opt_local.scrolloff = 0
          vim.b.snacks_scroll = false

          if vim.g.dashboard_saved_mouse == nil then
            vim.g.dashboard_saved_mouse = vim.go.mouse
          end

          vim.go.mouse = ""

          local group = vim.api.nvim_create_augroup("dashboard_mouse_restore", { clear = true })
          local function restore_mouse()
            local saved_mouse = vim.g.dashboard_saved_mouse
            if vim.bo.filetype == "snacks_dashboard" or saved_mouse == nil then
              return
            end

            vim.go.mouse = saved_mouse
            vim.g.dashboard_saved_mouse = nil
            pcall(vim.api.nvim_del_augroup_by_id, group)
          end

          vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
            group = group,
            callback = restore_mouse,
          })

          vim.schedule(function()
            vim.o.laststatus = 3
            vim.o.showtabline = 2
            require("lualine").refresh({ force = true, place = { "statusline", "tabline" } })
          end)
        end

        function _G.open_snacks_dashboard()
          local buf = vim.api.nvim_get_current_buf()
          if vim.bo[buf].filetype ~= "snacks_dashboard" then
            buf = vim.api.nvim_create_buf(false, true)
          end

          return Snacks.dashboard.open({
            buf = buf,
            win = vim.api.nvim_get_current_win(),
          })
        end

        vim.api.nvim_create_autocmd("User", {
          pattern = "SnacksDashboardOpened",
          callback = configure_dashboard_ui,
        })
      ''
    ];

    sops.secrets.github_token = {};

    # keep-sorted end

    programs.nvf.settings.vim = {
      # keep-sorted start block=yes newline_separated=yes
      # Provide CLI tools consumed by dashboard terminal sections.
      extraPackages = with pkgs; [
        # keep-sorted start
        dashboardGhNotify
        dwt1-shell-color-scripts
        # keep-sorted end
      ];

      # Global shortcut to reopen the startup dashboard at any time.
      keymaps = [
        {
          key = "<leader>d";
          mode = "n";
          action = "<cmd>lua _G.open_snacks_dashboard()<cr>";
          desc = "Open dashboard";
        }
      ];

      utility.snacks-nvim.setupOpts.dashboard = {
        enable = true;

        formats.icon = mkLuaInline ''
          function(item)
            if item.file and (item.icon == "file" or item.icon == "directory") then
              local icon = Snacks.dashboard.icon(item.file, item.icon)
              icon.hl = item.icon == "directory" and "SnacksDashboardDirIcon" or "SnacksDashboardFileIcon"
              return icon
            end

            return { item.icon, width = 1, hl = "icon" }
          end
        '';

        preset = {
          # Route dashboard pick actions through Telescope to keep the normal layout.
          pick = mkLuaInline ''
            function(cmd, opts)
              cmd = cmd == "files" and "find_files" or cmd
              return require("telescope.builtin")[cmd](opts or {})
            end
          '';

          # keep-sorted start block=yes newline_separated=yes
          # Define dashboard shortcuts explicitly and omit the default Config entry.
          keys = [
            {
              icon = " ";
              key = "f";
              desc = "Find File";
              action = ":lua Snacks.dashboard.pick('files')";
              text = mkLuaInline ''
                {
                  { " ", hl = "SnacksDashboardIcon" },
                  { "Find File", hl = "SnacksDashboardDesc", width = 50 },
                  { "f", hl = "SnacksDashboardKey" },
                }
              '';
            }
            {
              icon = " ";
              key = "n";
              desc = "New File";
              action = ":ene | startinsert";
              text = mkLuaInline ''
                {
                  { " ", hl = "SnacksDashboardIcon" },
                  { "New File", hl = "SnacksDashboardDesc", width = 50 },
                  { "n", hl = "SnacksDashboardKey" },
                }
              '';
            }
            {
              icon = " ";
              key = "g";
              desc = "Find Text";
              action = ":lua Snacks.dashboard.pick('live_grep')";
              text = mkLuaInline ''
                {
                  { " ", hl = "SnacksDashboardIcon" },
                  { "Find Text", hl = "SnacksDashboardDesc", width = 50 },
                  { "g", hl = "SnacksDashboardKey" },
                }
              '';
            }
            {
              icon = " ";
              key = "r";
              desc = "Recent Files";
              action = ":lua Snacks.dashboard.pick('oldfiles')";
              text = mkLuaInline ''
                {
                  { " ", hl = "SnacksDashboardIcon" },
                  { "Recent Files", hl = "SnacksDashboardDesc", width = 50 },
                  { "r", hl = "SnacksDashboardKey" },
                }
              '';
            }
            {
              icon = " ";
              key = "s";
              desc = "Restore Session";
              action = ":SessionManager load_session";
              text = mkLuaInline ''
                {
                  { " ", hl = "SnacksDashboardIcon" },
                  { "Restore Session", hl = "SnacksDashboardDesc", width = 50 },
                  { "s", hl = "SnacksDashboardKey" },
                }
              '';
            }
            {
              icon = " ";
              key = "q";
              desc = "Quit";
              action = ":qa";
              text = mkLuaInline ''
                {
                  { " ", hl = "SnacksDashboardIcon" },
                  { "Quit", hl = "SnacksDashboardDesc", width = 50 },
                  { "q", hl = "SnacksDashboardKey" },
                }
              '';
            }
          ];
          # keep-sorted end
        };

        sections = [
          {section = "header";}
          {
            section = "keys";
            gap = 1;
            padding = 1;
          }
          # Render startup metrics based on loaded runtime plugins.
          (mkLuaInline ''
            function()
              local metrics = vim.g.snacks_dashboard_metrics or {}
              local ms = metrics.ms
              if not ms and vim.g.snacks_dashboard_start_ns then
                ms = (vim.uv.hrtime() - vim.g.snacks_dashboard_start_ns) / 1e6
              end

              local loaded = metrics.loaded or 0
              local total = metrics.total or 0
              local text = {
                { "󱐋 ", hl = "SnacksDashboardIcon" },
                { "Neovim loaded ", hl = "SnacksDashboardFooter" },
                { string.format("%d/%d", loaded, total), hl = "SnacksDashboardKey" },
                { " plugins in ", hl = "SnacksDashboardFooter" },
                { string.format("%.2f ms", ms or 0), hl = "SnacksDashboardKey" },
              }

              return { pane = 1, text = text, padding = 1 }
            end
          '')
          {
            pane = 1;
            icon = "";
            title = "Recent Files";
            section = "recent_files";
            indent = 2;
            padding = 1;
          }
          {
            pane = 2;
            section = "terminal";
            cmd = "${getExe pkgs.dwt1-shell-color-scripts} -e square";
            height = 5;
            padding = [3 2];
          }
          {
            pane = 2;
            icon = "";
            title = "Notifications";
            section = "terminal";
            cmd = "${getExe dashboardGhNotify} -s -a -n4";
            height = 4;
            padding = 1;
            indent = 3;
            enabled = true;
          }
          {
            pane = 2;
            icon = "";
            title = "Git Status";
            section = "terminal";
            cmd = getExe (pkgs.writeShellApplication {
              name = "dashboard-git-status";
              runtimeInputs = with pkgs; [
                gawk
                git
              ];
              text = ''
                if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
                  git -c color.status=always status --short --branch --renames \
                    | awk 'NR <= 6 { print; seen = 1 } END { if (!seen) print "No git changes" }'
                else
                  printf '\n\n\n\n\n\n'
                fi
              '';
            });
            height = 6;
            padding = 1;
            indent = 3;
          }
          {
            pane = 2;
            icon = "";
            title = "Projects";
            section = "projects";
            indent = 2;
            padding = 1;
          }
        ];
      };

    };
    # keep-sorted end
  };
}
