{
  flake.modules.homeManager.atuin = {
    # keep-sorted start
    config,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (vars) groundDomain;
    inherit (config.xdg) cacheHome;
  in {
    programs.atuin = let
      logLevel = "error";
    in {
      enable = true;
      forceOverwriteSettings = true;

      # keep-sorted start block=yes newline_separated=yes
      daemon = {
        enable = true;
        inherit logLevel;
      };

      settings = {
        # keep-sorted start
        search-mode = "daemon-fuzzy";
        update_check = false;
        # keep-sorted end

        # keep-sorted start
        inline_height = 24;
        invert = true;
        show_help = false;
        show_tabs = false;
        style = "full";
        # keep-sorted end

        # keep-sorted start block=yes newline_separated=yes
        history_filter = [
          # keep-sorted start
          ''(^|[[:space:]])(export[[:space:]]+)?[A-Z_][A-Z0-9_]*(_TOKEN|_SECRET|_PASSWORD|_PASSWD|_API_KEY|_ACCESS_KEY|_SECRET_ACCESS_KEY)(="[^"]+"|=[^[:space:]]+)''
          ''(^|[[:space:]])--?(token|secret|password|passwd|api[-_]?key|access[-_]?key|client[-_]?secret)(=|[[:space:]]+)''
          ''(sk-[A-Za-z0-9_-]{20,}|ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|glpat-[A-Za-z0-9_-]{20,}|AKIA[0-9A-Z]{16})''
          # keep-sorted end
        ];

        keymap_mode = "vim-normal";

        logs = {
          level = logLevel;
          dir = "${cacheHome}/atuin/logs";
        };
        # keep-sorted end

        # keep-sorted start
        sync_address = "https://atuin.${groundDomain}";
        sync_frequency = 600;
        # keep-sorted end
      };
      # keep-sorted end
    };

    programs.fish.interactiveShellInitSnippets = [
      # Disable fish history in favor of atuin.
      ''
        set -gx fish_history ""
      ''
    ];
  };
}
