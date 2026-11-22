{
  perSystem = {pkgs, ...}: let
    inherit (pkgs) writeShellApplication;
  in {
    packages.audio-pm-ctl = writeShellApplication {
      name = "audio-pm-ctl";
      text = ''
        PARAM=/sys/module/snd_hda_intel/parameters/power_save
        STATE=/run/udev/snd-hda-intel-powersave

        save() {
          local current
          read -r current <"$PARAM"
          if [[ $current =~ ^[0-9]+$ && $current != 0 ]]; then
            printf '%s\n' "$current" >"$STATE"
          fi
        }

        is_on_ac() {
          local supply type online found_mains=0
          for supply in /sys/class/power_supply/*; do
            [[ -r "$supply/type" ]] || continue
            read -r type <"$supply/type"
            [[ $type == Mains ]] || continue
            found_mains=1
            if read -r online <"$supply/online" && [[ $online == 1 ]]; then
              return 0
            fi
          done
          # Desktops without a mains power-supply device are treated as plugged in.
          [[ $found_mains == 0 ]]
        }

        case "''${1:-}" in
        init)
          if is_on_ac; then
            save
            printf '0\n' >"$PARAM"
          fi
          ;;
        battery)
          value=10
          if [[ -r $STATE ]]; then
            read -r value <"$STATE" || value=10
            [[ $value =~ ^[0-9]+$ && $value != 0 ]] || value=10
          fi
          printf '%s\n' "$value" >"$PARAM"
          ;;
        ac)
          save
          printf '0\n' >"$PARAM"
          ;;
        *)
          printf 'Usage: %s {init|battery|ac}\n' "$0" >&2
          exit 1
          ;;
        esac
      '';
    };
  };
}
