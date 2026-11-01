{
  perSystem = {
    # keep-sorted start
    config,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (pkgs.lib) getExe;
    inherit
      (pkgs)
      # keep-sorted start
      runCommand
      writeShellApplication
      # keep-sorted end
      ;

    audioPmCtl = config.packages.audio-pm-ctl;
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

    checks.audio-pm-ctl =
      runCommand "audio-pm-ctl-tests" {
        nativeBuildInputs = [pkgs.bash];
      } ''
        set -euo pipefail
        bash -n ${getExe audioPmCtl}

        reset_fixture() {
          rm -rf fixture
          mkdir -p fixture/supplies
          param="$PWD/fixture/power_save"
          state="$PWD/fixture/saved"
          supplies="$PWD/fixture/supplies"
          helper="$PWD/fixture/helper.sh"
          substitute ${getExe audioPmCtl} "$helper" \
            --replace-fail /sys/module/snd_hda_intel/parameters/power_save "$param" \
            --replace-fail /run/udev/snd-hda-intel-powersave "$state" \
            --replace-fail /sys/class/power_supply "$supplies"
          printf '10\n' > "$param"
        }

        supply() {
          mkdir -p "$supplies/$1"
          printf '%s\n' "$2" > "$supplies/$1/type"
          printf '%s\n' "$3" > "$supplies/$1/online"
        }

        assert_value() {
          if [[ $(<"$1") != "$2" ]]; then
            printf 'Unexpected value in %s; expected %s\n' "$1" "$2" >&2
            exit 1
          fi
        }

        reset_fixture
        bash "$helper" init
        assert_value "$param" 0
        assert_value "$state" 10
        echo 'ok 1 - desktop init saves and disables'

        reset_fixture
        supply AC Mains 0
        bash "$helper" init
        assert_value "$param" 10
        test ! -e "$state"
        echo 'ok 2 - battery init leaves power saving enabled'

        reset_fixture
        supply AC0 Mains 0
        supply AC1 Mains 1
        bash "$helper" init
        assert_value "$param" 0
        echo 'ok 3 - any online mains is sufficient'

        reset_fixture
        supply BAT0 Battery 0
        bash "$helper" init
        assert_value "$param" 0
        echo 'ok 4 - battery device is not mains'

        reset_fixture
        printf '5\n' > "$param"
        bash "$helper" ac
        bash "$helper" battery
        assert_value "$param" 5
        echo 'ok 5 - AC and battery round trip restores value'

        reset_fixture
        bash "$helper" ac
        bash "$helper" ac
        bash "$helper" battery
        assert_value "$param" 10
        echo 'ok 6 - repeated AC preserves saved value'

        reset_fixture
        bash "$helper" init
        bash "$helper" init
        assert_value "$state" 10
        echo 'ok 7 - repeated init preserves saved value'

        reset_fixture
        printf '0\n' > "$param"
        bash "$helper" battery
        assert_value "$param" 10
        echo 'ok 8 - missing state falls back to ten'

        reset_fixture
        for value in "" garbage 0; do
          printf '%s\n' "$value" > "$state"
          bash "$helper" battery
          assert_value "$param" 10
        done
        echo 'ok 9 - invalid state falls back to ten'

        reset_fixture
        if bash "$helper" unknown; then
          echo 'Unknown action unexpectedly succeeded' >&2
          exit 1
        fi
        assert_value "$param" 10
        echo 'ok 10 - invalid action fails without changing state'
        echo '1..10'
        touch "$out"
      '';
  };
}
