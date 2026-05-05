{
  flake.modules.homeManager.ripgrep = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;
    ripgrep = getExe config.programs.ripgrep.package;
  in {
    programs.ripgrep.enable = true;

    home.shellAliases = {
      # keep-sorted start
      egrep = ripgrep;
      fgrep = "${ripgrep} -F";
      grep = ripgrep;
      # keep-sorted end
    };
  };
}
