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
    programs.fish.shellAbbrs.of = "onefetch";
  };
}
