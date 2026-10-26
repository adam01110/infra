{
  flake.modules.homeManager.surge = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) escapeShellArg getExe;
    inherit (lib.hm.dag) entryAfter;

    inherit (pkgs) surge-downloader;

    tomlFormat = pkgs.formats.toml {};

    colors = config.lib.stylix.colors.withHashtag;
    themePath = "${config.xdg.configHome}/surge/themes/stylix.toml";
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

    # Preserve other settings edited through the TUI.
    home.activation.configureSurge = entryAfter ["linkGeneration"] ''
      run ${getExe surge-downloader} config General.Live_Speed_Graph true
      run ${getExe surge-downloader} config General.Show_Speed_Graph true
      run ${getExe surge-downloader} config General.Skip_Update_Check true
      run ${getExe surge-downloader} config Network.Max_Concurrent_Downloads 4
      run ${getExe surge-downloader} config Network.Max_Concurrent_Probes 4
      run ${getExe surge-downloader} config General.Theme ${
        if config.stylix.polarity == "light"
        then "1"
        else "2"
      }
      run ${getExe surge-downloader} config General.Theme_Path ${escapeShellArg themePath}
    '';

    xdg.configFile."surge/themes/stylix.toml".source = tomlFormat.generate "surge-stylix.toml" {
      colors = with colors; {
        name = "Stylix";
        primary = {
          background = base00;
          foreground = base05;
        };
        normal = {
          # keep-sorted start
          black = base01;
          blue = base0D;
          cyan = base0C;
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
          cyan = base0C;
          green = base0B;
          magenta = base0E;
          red = base08;
          white = base07;
          yellow = base0A;
          # keep-sorted end
        };
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
        ExecStart = "${getExe surge-downloader} server start --port 1700 --output ${config.xdg.userDirs.download}";
        Restart = "on-failure";
        RestartSec = 5;
        UMask = "0077";
      };

      Install.WantedBy = ["default.target"];
    };
  };
}
