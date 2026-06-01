{
  flake.modules.homeManager.onefetch = {
    # keep-sorted start
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (pkgs) onefetch;
  in {
    home.packages = [onefetch];
    home.shellAbbreviations.of = "onefetch";
  };
}
