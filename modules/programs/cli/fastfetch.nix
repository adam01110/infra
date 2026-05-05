{
  # keep-sorted start
  lib,
  pkgs,
  # keep-sorted end
  ...
}: let
  inherit (builtins) fromJSON;
  inherit (lib) getExe;
  inherit (pkgs) writeShellApplication;

  # Escape code for fastfetch color formatting.
  esc = fromJSON "\"\\u001b\"";
in {
  programs.fastfetch = {
    enable = true;

    settings = {
      # Use custom logo and kitty terminal image display.
      logo = {
        source = ./logo.png;
        type = "kitty";
        height = 15;
        width = 35;
      };

      # Configure display formatting and binary prefix standards.
      display = {
        separator = " ";
        size.binaryPrefix = "jedec";
      };

      # Define information modules to show in system overview.
      modules = [
        "break"

        {
          type = "os";
          key = "{#7}  DISTRO ";
          keyColor = "blue";
          format = "${esc}[34m{#1}{#7} {3} ";
        }

        {
          type = "kernel";
          key = "│ ├ KERNEL";
          keyColor = "34";
          format = "{2}";
        }

        {
          type = "packages";
          key = "│ ├󰏖 PACKAGES";
          keyColor = "34";
        }

        {
          type = "shell";
          key = "│ ├ SHELL";
          keyColor = "34";
        }

        {
          type = "command";
          key = "│ ├󰅐 OS-AGE";
          keyColor = "34";

          # Calculate system installation age from root filesystem birth time.
          text = getExe (writeShellApplication {
            name = "os-age";
            runtimeInputs = [pkgs.coreutils];
            text = ''
              birth_install="$(stat -c %W /)"
              current="$(date +%s)"
              time_progression="$((current - birth_install))"
              days_difference="$((time_progression / 86400))"

              echo "$days_difference days"
            '';
          });
        }

        {
          type = "uptime";
          key = "│ └󰅐 UPTIME";
          keyColor = "34";
        }

        {
          type = "custom";
          format = "{#1}${esc}[34m└─────────────────────────────────────────────────────────────";
        }

        {
          type = "wm";
          key = "{#7}  DE/WM ";
          keyColor = "36";
          format = "${esc}[36m{#1}{#7} {2} {3} ";
        }

        {
          type = "de";
          key = "│ ├󰧨 DE";
          keyColor = "cyan";
        }

        {
          type = "lm";
          key = "│ ├󰧨 LM";
          keyColor = "cyan";
        }

        {
          type = "theme";
          key = "│ ├󰉼 THEME";
          keyColor = "cyan";
        }

        {
          type = "icons";
          key = "│ ├󰀻 ICONS";
          keyColor = "cyan";
        }

        {
          type = "terminal";
          key = "│ ├ TERMINAL";
          keyColor = "cyan";
        }

        {
          type = "terminalfont";
          key = "│ └ FONT";
          keyColor = "cyan";
        }

        {
          type = "custom";
          format = "{#1}${esc}[36m└─────────────────────────────────────────────────────────────";
        }

        {
          type = "board";
          key = "{#7}  HARDWARE ";
          keyColor = "31";
          format = "${esc}[31m{#1}{#7} {1} ({2}) ";
        }

        {
          type = "cpu";
          key = "│ ├ CPU";
          keyColor = "red";
        }

        {
          type = "gpu";
          key = "│ ├󰍛 GPU";
          keyColor = "red";
          format = "{2} {3}";
        }

        {
          type = "memory";
          key = "│ ├󰑭 RAM";
          keyColor = "red";
          format = "{4} {1} / {2} ({3})";
        }

        {
          type = "disk";
          key = "│ ├ DISKS";
          keyColor = "red";
        }

        {
          type = "custom";
          format = "{#1}${esc}[31m└─────────────────────────────────────────────────────────────";
        }

        {
          type = "display";
          key = "{#7} 󰍹 DISPLAY ";
          keyColor = "38";
          format = "{#1}{#7}${esc}[32m {6} {1}x{2} @{3}Hz ({7}) ";
        }

        {
          type = "media";
          key = "│ ├󰝚 TRACK";
          keyColor = "38";
          format = "{3} - {1} ({5})";
        }

        {
          type = "sound";
          key = "│ └ VOLUME";
          keyColor = "38";
        }

        {
          type = "custom";
          format = "{#1}${esc}[37m└─────────────────────────────────────────────────────────────";
        }
      ];
    };
  };
}
