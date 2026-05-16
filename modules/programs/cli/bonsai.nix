{self, ...}: {
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
    imports = [self.modules.homeManager.nur];

    home = {
      packages = [bonsai];
      shellAliases.bonsai = "${getExe bonsai} -S";
    };
  };
}
