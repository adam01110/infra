{
  flake.modules.homeManager.bonsai = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;
    bonsai = pkgs.nur.repos.Dev380.rbonsai;
  in {
    home = {
      packages = [bonsai];
      shellAliases.bonsai = "${getExe bonsai} -S";
    };
  };
}
