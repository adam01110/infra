{
  flake.modules.homeManager.wordcraft = {pkgs, ...}: {
    home.packages = [pkgs.wordcraft];
  };
}
