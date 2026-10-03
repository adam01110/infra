{
  flake.modules.homeManager.neovim = {
    # keep-sorted start
    config,
    # keep-sorted end
    ...
  }: let
    colors = config.lib.stylix.colors.withHashtag;
  in {
    programs.nvf.settings.vim = {
      highlight = {
        # keep-sorted start
        CursorTabCompletion.fg = colors.base04;
        CursorTabJumpSymbol.fg = colors.base03;
        # keep-sorted end
      };

      assistant.cursortab = {
        enable = true;

        setupOpts = {
          blink = {
            # keep-sorted start
            enabled = true;
            ghost_text = false;
            # keep-sorted end
          };

          # Preserve upstream ignores when replacing the default list.
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
          provider.type = "copilot";
        };
      };
    };
  };
}
