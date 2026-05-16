{self, ...}: {
  flake.modules.homeManager.onefetch = {
    # keep-sorted start
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (pkgs) onefetch;
  in {
    imports = [self.modules.homeManager.shellAbbreviations];

    home.packages = [onefetch];
    home.shellAbbreviations.of = "onefetch";
  };
}
