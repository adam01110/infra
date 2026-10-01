{
  perSystem = {pkgs, ...}: let
    inherit (pkgs) fetchPypi writeShellApplication;
    inherit (pkgs.python3Packages) buildPythonApplication;

    pptx2md = buildPythonApplication {
      pname = "pptx2md";
      version = "2.0.6";
      pyproject = true;
      src = fetchPypi {
        pname = "pptx2md";
        version = "2.0.6";
        hash = "sha256-KtwFLZ+14DGwdgiH7qkx58eMIIt7JECxBGijwodLTkQ=";
      };
      build-system = [pkgs.python3Packages.poetry-core];
      dependencies = with pkgs.python3Packages; [
        # keep-sorted start
        numpy
        pillow
        pydantic
        python-pptx
        rapidfuzz
        scipy
        tqdm
        # keep-sorted end
      ];
      pythonImportsCheck = ["pptx2md"];
      meta.mainProgram = "pptx2md";
    };
  in {
    packages.pptx2md-adapter = writeShellApplication {
      name = "pptx2md.sh";
      runtimeInputs = [pkgs.coreutils pptx2md];
      text = ''
        set -o errtrace -o errexit -o nounset -o pipefail
        [[ "''${TRACE:-0}" == "1" ]] && set -o xtrace

        shopt -s inherit_errexit
        IFS=$'\n\t'
        PS4='+\t '

        error_handler() { printf 'Error: In %s Line %s exited with Status %s\n' "''${BASH_SOURCE[0]}" "$1" "$2" >&2; }
        trap 'error_handler ''${LINENO} $?' ERR

        if [ $# -eq 0 ]; then
          printf 'Usage: pptx2md.sh [options] <file|->\n' >&2
          exit 2
        fi

        output_file="$(mktemp "''${TMPDIR:-/tmp}/tempXXXXXXXXXX.md")"
        input_file=""
        cleanup() {
          rm -f "$output_file"
          if [ -n "$input_file" ]; then
            rm -f "$input_file"
          fi
        }
        trap cleanup EXIT

        for arg; do :; done
        if [ "$arg" = "-" ]; then
          input_file="$(mktemp "''${TMPDIR:-/tmp}/tempXXXXXXXXXX.pptx")"
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
