{
  flake.modules.homeManager.neovim = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit (lib.self) blendHex;

    colors = config.lib.stylix.colors.withHashtag;
  in {
    programs.nvf.settings.vim = {
      highlight = {
        # keep-sorted start block=yes newline_separated=yes
        CursorTabAddition = {
          bg = blendHex 15 colors.base00 colors.base0B;
          fg = colors.base0B;
        };

        CursorTabCompletion.fg = colors.base04;

        CursorTabDeletion = {
          bg = blendHex 15 colors.base00 colors.base08;
          fg = colors.base08;
        };

        CursorTabJumpSymbol.fg = colors.base03;

        CursorTabJumpText = {
          bg = colors.base01;
          fg = colors.base04;
        };

        CursorTabModification = {
          bg = blendHex 15 colors.base00 colors.base0A;
          fg = colors.base0A;
        };
        # keep-sorted end
      };

      assistant.cursortab = {
        enable = true;

        setupOpts = {
          provider.type = "copilot";

          blink = {
            # keep-sorted start
            enabled = true;
            ghost_text = false;
            # keep-sorted end
          };

          behavior.ignore_paths = [
            # keep-sorted start
            "*-lock.json"
            "*.csv"
            "*.gz"
            "*.key"
            "*.lock"
            "*.log"
            "*.map"
            "*.min.css"
            "*.min.js"
            "*.parquet"
            "*.pem"
            "*.png"
            "*.sum"
            "*.tar"
            "*.tsv"
            "*.zip"
            ".env"
            ".env.*"
            # keep-sorted end
          ];

          keymaps = {
            # keep-sorted start
            accept = "<M-y>";
            partial_accept = "<M-Y>";
            trigger = "<M-p>";
            # keep-sorted end
          };
        };
      };
    };
  };
}
