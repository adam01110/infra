{
  flake.modules.homeManager.surge = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (builtins) isBool;
    inherit (lib) boolToString concatMapAttrsStringSep escapeShellArgs getExe;
    inherit (pkgs) writeShellScript;

    # Backport saved settings loading for the connected TUI in 0.12.2.
    surge-downloader = pkgs.surge-downloader.overrideAttrs (old: {
      patches = (old.patches or []) ++ [./surge-connect-settings.patch];
      postCheck =
        (old.postCheck or "")
        + ''
          go test ./cmd -run '^TestNewRemoteRootModel' -count=1
        '';
    });

    tomlFormat = pkgs.formats.toml {};

    colors = config.lib.stylix.colors.withHashtag;
    themePath = "${config.xdg.configHome}/surge/themes/stylix.toml";

    settings = {
      # keep-sorted start
      "General.Live_Speed_Graph" = true;
      "General.Show_Speed_Graph" = true;
      "General.Skip_Update_Check" = true;
      "General.Theme" =
        if config.stylix.polarity == "light"
        then 1
        else 2;
      "General.Theme_Path" = themePath;
      "Network.Max_Concurrent_Downloads" = 4;
      "Network.Max_Concurrent_Probes" = 4;
      # keep-sorted end
    };

    configureSurge = writeShellScript "configure-surge" (
      "set -e\n"
      + concatMapAttrsStringSep "\n" (
        name: value: "${getExe surge-downloader} config ${escapeShellArgs [
          name
          (
            if isBool value
            then boolToString value
            else toString value
          )
        ]}"
      )
      settings
    );
  in {
    home.packages = [surge-downloader];

    programs.fish.functions.surge = {
      description = "Connect to Surge or run an explicit command";
      wraps = "surge";
      body = ''
        if test (count $argv) -eq 0
          ${getExe surge-downloader} connect
        else
          ${getExe surge-downloader} $argv
        end
      '';
    };

    xdg.configFile."surge/themes/stylix.toml".source = tomlFormat.generate "surge-stylix.toml" {
      colors = with colors; {
        name = "Stylix";
        primary = {
          # keep-sorted start
          accent = base0D;
          background = base00;
          foreground = base05;
          # keep-sorted end
        };
        normal = {
          # keep-sorted start
          black = base03;
          blue = base0D;
          cyan = base04;
          green = base0B;
          magenta = base0E;
          red = base08;
          white = base05;
          yellow = base0A;
          # keep-sorted end
        };
        bright = {
          # keep-sorted start
          black = base03;
          blue = base0D;
          cyan = base04;
          green = base0B;
          magenta = base0E;
          red = base08;
          white = base07;
          yellow = base0A;
          # keep-sorted end
        };

        # Speed graph gradient, quiet at the bottom and accent at the top.
        graph = [
          base03
          base04
          base0D
          base0D
        ];
      };
    };

    xdg.desktopEntries.surge = {
      name = "Surge";
      genericName = "Download Manager";
      icon = "folder-download";

      exec = let
        terminalCommand = getExe config.xdg.terminal-exec.package;
      in "${terminalCommand} --title=Surge ${getExe surge-downloader} connect";

      categories = [
        # keep-sorted start
        "ConsoleOnly"
        "FileTransfer"
        "Network"
        # keep-sorted end
      ];
    };

    # Keep the token-authenticated API available to the browser extension.
    systemd.user.services.surge = {
      Unit = {
        Description = "Surge download manager";
        After = ["network-online.target"];
        Wants = ["network-online.target"];
      };

      Service = {
        ExecStartPre = ["${configureSurge}"];
        ExecStart = "${getExe surge-downloader} server start --port 1700 --output ${config.xdg.userDirs.download}";
        Restart = "on-failure";
        RestartSec = 5;
        UMask = "0077";
      };

      Install.WantedBy = ["default.target"];
    };
  };
}
