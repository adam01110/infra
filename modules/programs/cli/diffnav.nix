{
  flake.modules.homeManager.diffnav = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      getExe
      mkForce
      # keep-sorted end
      ;
    inherit (pkgs) writeShellApplication;

    diffnavPager = writeShellApplication {
      name = "diffnav-pager";
      text = ''
        diff_file="$(mktemp)"
        trap 'rm -f "$diff_file"' EXIT

        cat > "$diff_file"

        if [[ ! -s "$diff_file" ]]; then
          exit 0
        fi

        exec ${getExe pkgs.diffnav} "$@" < "$diff_file"
      '';
    };
  in {
    home.packages = [pkgs.diffnav];

    programs.git.iniContent.pager.diff = mkForce (getExe diffnavPager);
  };
}
