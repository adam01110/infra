{
  flake.modules.homeManager.neovim = _: {
    programs.nvf.settings.vim = {
      # keep-sorted start block=yes newline_separated=yes
      # Add a shortcut to toggle markview rendering.
      keymaps = [
        {
          key = "<leader>m";
          mode = "n";
          action = "<CMD>Markview<CR>";
          desc = "Toggle `markview` globally";
        }
      ];

      languages.markdown = {
        enable = true;

        # keep-sorted start
        extraDiagnostics.types = ["rumdl"];
        format.type = ["rumdl"];
        lsp.servers = ["rumdl"];
        # keep-sorted end

        extensions.markview-nvim = {
          enable = true;

          setupOpts = {
            # keep-sorted start block=yes newline_separated=yes
            experimental.prefer_nvim = true;

            markdown = {
              enable = true;
              use_virt_lines = true;

              # keep-sorted start block=yes newline_separated=yes
              headings = {
                # keep-sort start numeric=yes
                heading_1.icon = "󰎤 ";
                heading_2.icon = "󰎧 ";
                heading_3.icon = "󰎪 ";
                heading_4.icon = "󰎭 ";
                heading_5.icon = "󰎱 ";
                heading_6.icon = "󰎳 ";
                # keep-sort end

                # keep-sort start numeric=yes
                setext_1.icon = "󰎤 ";
                setext_2.icon = "󰎧 ";
                # keep-sort end
              };

              tables.parts = {
                # keep-sort start
                top = ["┌" "─" "┐" "┬"];
                bottom = ["└" "─" "┘" "┴"];
                overlap = ["├" "─" "┤" "┼"];
                align_left = "─";
                align_right = "─";
                align_center = ["─" "─"];
                # keep-sort end
              };
              # keep-sorted end

              horizontal_rules = "presets.dashed";
            };

            preview = {
              # keep-sorted start
              enable = false;
              linewise_hybrid_mode = true;
              # keep-sorted end

              icon_provider = "devicons";
              filetypes = ["markdown"];

              # keep-sorted start block=yes newline_separated=yes
              hybrid_modes = [
                # keep-sorted start
                "V"
                "n"
                "v"
                # keep-sorted end
              ];

              modes = [
                # keep-sorted start
                "V"
                "n"
                "no"
                "v"
                # keep-sorted end
              ];
              # keep-sorted end
            };
            # keep-sorted end
          };
        };
      };
      # keep-sorted end
    };
  };
}
