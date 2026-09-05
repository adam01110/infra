{
  flake.modules.homeManager.scope-tui = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;

    pkg = pkgs.scope-tui;
  in {
    home = {
      packages = [pkg];
      shellAliases.scope-tui = "${getExe pkg} --scatter pulse @DEFAULT_MONITOR@";
    };
  };
}
