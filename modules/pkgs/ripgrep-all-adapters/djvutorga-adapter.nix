let
  inherit (builtins) attrValues;
in {
  perSystem = {pkgs, ...}: {
    packages.djvutorga-adapter = pkgs.writeShellApplication {
      name = "djvutorga";
      runtimeInputs = attrValues {
        inherit
          (pkgs)
          # keep-sorted start
          coreutils
          djvulibre
          # keep-sorted end
          ;
      };
      text = ''
        set -o errtrace -o errexit -o nounset -o pipefail
        [[ "''${TRACE:-0}" == "1" ]] && set -o xtrace

        shopt -s inherit_errexit
        IFS=$'\n\t'
        PS4='+\t '

        temp_file="$(mktemp "''${TMPDIR:-/tmp}/tempXXXXXXXXXX.djvu")"
        cleanup() {
          rm -f "''${temp_file}"
        }
        trap cleanup EXIT

        cat > "''${temp_file}"

        declare -a file_to_page=()
        while IFS= read -r file_info; do
          page="''${file_info%% [APIT]*}"
          page="''${page// /}"
          file_to_page+=("''${page}")
        done < <(djvused "''${temp_file}" -e 'ls')

        file=0
        page=""
        while IFS= read -r line; do
          if [[ "''${line}" == *$'\f'* ]]; then
            pagebreaks="''${line//[^$'\f']/}"
            file=$((file + ''${#pagebreaks}))
            page="''${file_to_page[$file]:-}"
            line="''${line//$'\f'/}"
          fi
          printf 'Page %s: %s\n' "''${page}" "''${line}"
        done < <(djvused "''${temp_file}" -e 'print-pure-txt')
      '';
    };
  };
}
