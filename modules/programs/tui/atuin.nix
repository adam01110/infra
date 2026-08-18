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

    aiAuthTokenPath = config.sops.secrets."atuin/ai_auth_token".path;
  in {
    sops.secrets."atuin/ai_auth_token" = {};

    programs.atuin = let
      logLevel = "error";
    in {
      enable = true;
      enableFishIntegration = true;
      forceOverwriteSettings = true;

      # keep-sorted start block=yes newline_separated=yes
      daemon = {
        enable = true;
        inherit logLevel;
      };

      settings = {
        ai = {
          enabled = true;
          endpoint = "https://atuin.${groundDomain}";
          endpoint_protocol = "oss";
          model = "deepseek-v4-flash";
        };

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
          ''(?i)authorization:[[:space:]]+(bearer|basic|token|apikey|api[_-]?key|access[_-]?token)[[:space:]=]+''
          ''(^|[[:space:]])(export[[:space:]]+)?[A-Z_][A-Z0-9_]*(_TOKEN|_SECRET|_PASSWORD|_PASSWD|_API_KEY|_ACCESS_KEY|_SECRET_ACCESS_KEY)(="[^"]+"|=[^[:space:]]+)''
          ''(^|[[:space:]])--?(token|secret|password|passwd|api[-_]?key|access[-_]?key|client[-_]?secret)(=|[[:space:]]+)''
          ''(sk-[A-Za-z0-9_-]{20,}|[sp]k_(live|test)_[A-Za-z0-9]{20,}|rk_live_[A-Za-z0-9]{20,}|ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|glpat-[A-Za-z0-9_-]{20,}|AKIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]{10,}|SG\.[A-Za-z0-9_\-\.]{20,}|AIza[A-Za-z0-9_\-]{30,}|ya29\.[A-Za-z0-9_\-]{10,}|nvapi-[A-Za-z0-9_-]{20,}|hf_[A-Za-z0-9]{20,})''
          ''-----BEGIN (RSA |EC |DSA |OPENSSH |PGP |ENCRYPTED )?PRIVATE KEY-----''
          ''[?&][a-z0-9_-]*(secret|token|key|passwd|password|apikey|api[_-]?key|access[_-]?token|refresh[_-]?token|signature|session[_-]?key|credential)[=][^[:space:]&'"<>]+''
          ''[a-z][a-z0-9+.-]*://[^/@[:space:]'"]+:[^@[:space:]'"]+@''
          ''eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}''
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
      # Load endpoint authentication outside the Nix store.
      ''
        set -gx ATUIN_AI__API_TOKEN (string trim < ${aiAuthTokenPath})
      ''

      # Disable fish history in favor of atuin.
      ''
        set -gx fish_history ""
      ''
    ];
  };
}
