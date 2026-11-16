{
  flake.aspects.neovim.homeManager = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (builtins) readFile;
    inherit (lib) escapeShellArg getExe;
    inherit (lib.generators) mkLuaInline toLua;

    colors = config.lib.stylix.colors.withHashtag;
  in {
    # keep-sorted start block=yes newline_separated=yes
    programs.nvf.settings.vim.luaConfigPreSnippets = [
      # Footer reads these cached metrics.
      (readFile ./metrics.lua)

      ''
        do
          local setup = (function()
            ${readFile ./highlights.lua}
          end)()

          setup(${toLua {} colors.base0E})
        end
      ''

      (readFile ./ui.lua)
    ];

    sops.secrets.github_token = {};

    # keep-sorted end

    programs.nvf.settings.vim = {
      # keep-sorted start block=yes newline_separated=yes
      extraPackages = with pkgs; [
        # keep-sorted start
        dashboard-gh-notify
        dwt1-shell-color-scripts
        # keep-sorted end
      ];

      keymaps = [
        {
          key = "<leader>D";
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
          pick = mkLuaInline ''
            function(cmd, opts)
              cmd = cmd == "files" and "find_files" or cmd
              return _G.telescope_pick(cmd, opts)
            end
          '';

          # keep-sorted start block=yes newline_separated=yes
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
            cmd = "GH_TOKEN_FILE=${escapeShellArg config.sops.secrets.github_token.path} ${getExe pkgs.dashboard-gh-notify} -s -a -n4";
            height = 4;
            padding = 1;
            indent = 3;
            enabled = true;
          }
          {
            pane = 2;
            icon = "";
            title = "VCS Status";
            section = "terminal";
            cmd = getExe pkgs.dashboard-vcs-status;
            height = 6;
            padding = 1;
            indent = 3;
            # Avoid showing stale terminal cache before live status arrives.
            random = 1;
            ttl = 0;
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
