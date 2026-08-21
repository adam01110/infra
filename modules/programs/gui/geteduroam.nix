{
  flake.modules.homeManager.geteduroam = {pkgs, ...}: {
    home.packages = [pkgs.geteduroam];
  };
}
