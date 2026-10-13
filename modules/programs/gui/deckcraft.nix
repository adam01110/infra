{
  flake.modules.homeManager.deckcraft = {pkgs, ...}: {
    home.packages = [pkgs.nur.repos.quriosity.deckcraft];
  };
}
