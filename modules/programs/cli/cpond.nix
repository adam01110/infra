{
  flake.aspects.cpond.homeManager = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;

    inherit (pkgs.nur.repos.adam0) cpond;
  in {
    home = {
      packages = [cpond];
      shellAliases.cpond = "${getExe cpond} -b -c 16";
    };
  };
}
