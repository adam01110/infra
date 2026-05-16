{
  flake.modules.homeManager.fish = {pkgs, ...}: {
    programs.fish.plugins = let
      mkPlugin = source: pkg: {
        name = pkg;
        inherit (source.${pkg}) src;
      };
    in
      map (mkPlugin pkgs.fishPlugins) [
        # keep-sorted start
        "autopair"
        "done"
        "fish-you-should-use"
        "fishbang"
        # keep-sorted end
      ];
  };
}
