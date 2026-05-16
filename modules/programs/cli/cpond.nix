{self, ...}: {
  flake.modules.homeManager.cpond = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;
    inherit (pkgs.nur.repos.adam0) cpond;
  in {
    imports = [self.modules.homeManager.nur];

    home = {
      packages = [cpond];
      shellAliases.cpond = "${getExe cpond} -b -c 16";
    };
  };
}
