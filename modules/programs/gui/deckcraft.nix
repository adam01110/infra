{
  flake.aspects.deckcraft.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.deckcraft];
  };
}
