{
  flake.modules.homeManager.speedtest = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;

    pkg = pkgs.speedtest-go;
  in {
    home = {
      packages = [pkg];
      shellAliases.speedtest = getExe pkg;
    };
  };
}
