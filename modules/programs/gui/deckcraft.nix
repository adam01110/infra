{
  flake.modules.homeManager.deckcraft = {pkgs, ...}: {
    home.packages = [pkgs.deckcraft];
  };
}
