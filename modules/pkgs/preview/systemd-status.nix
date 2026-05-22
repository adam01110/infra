{
  perSystem = {pkgs, ...}: let
    inherit (pkgs) writeShellApplication;
  in {
    packages.systemd-status-preview = writeShellApplication {
      # Share one preview helper across tools that inspect systemd units.
      name = "systemd-status-preview";
      runtimeInputs = with pkgs; [
        # keep-sorted start
        bat
        coreutils
        gawk
        gnugrep
        gnused
        systemd
        # keep-sorted end
      ];
      text = ''
        mode="unit"

        if [ "''${1-}" = "--from-path" ]; then
          mode="path"
          shift
        fi

        target="''${1-}"

        if [ -z "$target" ]; then
          exit 0
        fi

        unit="$target"
        scope=--system

        if [ "$mode" = "path" ]; then
          unit="$(basename -- "$target")"

          if printf '%s\n' "$target" | grep -q '/systemd/user/'; then
            scope=--user
          fi
        fi

        status="$(SYSTEMD_COLORS=1 systemctl "$scope" status "$unit" --no-pager --full --lines=50 2>/dev/null)"

        if [ -z "$status" ]; then
          exit 0
        fi

        sep="$(printf '%s\n' "$status" | gawk '/^[[:space:]]*$/ { print NR; exit }')"

        if [ -n "$sep" ]; then
          printf '%s\n' "$status" | sed -n "1,$((sep - 1))p"

          if [ "$(printf '%s\n' "$status" | wc -l)" -gt "$sep" ]; then
            printf '\n'
            printf '%s\n' "$status" | tail -n "+$((sep + 1))" | bat --language=syslog --theme=ansi --style=plain --color=always
          fi
        else
          printf '%s\n' "$status"
        fi
      '';
    };
  };
}
