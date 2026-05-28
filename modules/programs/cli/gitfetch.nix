{self, ...}: {
  flake.modules.homeManager.gitfetch = {
    # keep-sorted start
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (pkgs) gitfetch;
  in {
    imports = [
      {
        key = "homeManager-shellAbbreviations";
        imports = [self.modules.homeManager.shellAbbreviations];
      }
    ];

    home.packages = [gitfetch];
    home.shellAbbreviations.gf = "gitfetch";
  };
}
