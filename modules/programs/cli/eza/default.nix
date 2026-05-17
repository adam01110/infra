{
  flake.modules.homeManager.eza = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;
  in {
    programs.eza = {
      enable = true;

      colors = "always";
      icons = "always";
      extraOptions = [
        # keep-sorted start
        "--all"
        "--group-directories-first"
        "--long"
        "--mounts"
        "--time-style=long-iso"
        # keep-sorted end
      ];
    };

    home.shellAliases = let
      eza = getExe config.programs.eza.package;
      ezaTree = "${eza} --tree --git-ignore";
    in {
      # keep-sorted start
      lt = ezaTree;
      tree = ezaTree;
      # keep-sorted end
    };
  };
}
