{
  flake.modules.homeManager.gitfetch = {
    # keep-sorted start
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (pkgs) gitfetch;
  in {
    home.packages = [gitfetch];
    programs.fish.shellAbbrs.gf = "gitfetch";
  };
}
