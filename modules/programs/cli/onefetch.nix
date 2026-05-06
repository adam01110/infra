{
  flake.modules.homeManager.onefetch = {
    # keep-sorted start
    pkgs,
    # keep-sorted end
    ...
  }: let
    onefetch = pkgs.onefetch;
  in {
    home.packages = [onefetch];
    programs.fish.shellAbbrs.of = "onefetch";
  };
}
