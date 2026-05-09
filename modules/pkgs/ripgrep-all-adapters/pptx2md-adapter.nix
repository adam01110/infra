{
  perSystem = {pkgs, ...}: let
    inherit (builtins) attrValues;
    inherit (pkgs) writeShellApplication;
  in {
    packages.pptx2md-adapter = writeShellApplication {
      name = "pptx2md.sh";
      runtimeInputs = attrValues {
        inherit
          (pkgs)
          # keep-sorted start
          coreutils
          # keep-sorted end
          ;
      };
      text = ''
        set -o errtrace -o errexit -o nounset -o pipefail
        [[ "''${TRACE:-0}" == "1" ]] && set -o xtrace

        shopt -s inherit_errexit
        IFS=$'\n\t'
        PS4='+\t '

        error_handler() { cat >&2 "Error: In ''${BASH_SOURCE[0]} Line ''${1} exited with Status ''${2}"; }
        trap 'error_handler ''${LINENO} $?' ERR

        if ! command -v pptx2md >/dev/null 2>&1; then
          cat >&2 "pptx2md is required in PATH for the pptx adapter."
          exit 127
        fi

        output_file="$(mktemp "''${TMPDIR:-/tmp}/tempXXXXXXXXXX.md")"
        cleanup_output() {
          rm -f "$output_file"
        }
        trap cleanup_output EXIT

        for arg; do :; done
        if [ "$arg" = "-" ]; then
          input_file="$(mktemp "''${TMPDIR:-/tmp}/tempXXXXXXXXXX.pptx")"
          cleanup_input() {
            rm -f "$input_file"
          }
          trap cleanup_input EXIT

          cat > "$input_file"

          if [ $# -gt 1 ]; then
            args=("$@")
            unset "args[$((''${#args[@]} - 1))]"
            pptx2md "''${args[@]}" "$input_file" --output "$output_file" >/dev/null
          else
            pptx2md "$input_file" --output "$output_file" >/dev/null
          fi
        else
          pptx2md "$@" --output "$output_file" >/dev/null
        fi

        cat --squeeze-blank "$output_file"
      '';
    };
  };
}
