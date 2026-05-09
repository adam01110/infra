{
  flake.modules.homeManager.loupe = {pkgs, ...}: {
    home.packages = [pkgs.loupe];
  };
}
