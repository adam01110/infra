{
  flake.modules.homeManager.speedtest = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;
    speedtest = pkgs.speedtest-go;
  in {
    home = {
      packages = [speedtest];
      shellAliases.speedtest = getExe pkgs.speedtest-go;
    };
  };
}
