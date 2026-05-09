{
  flake.modules.homeManager.krita = {pkgs, ...}: {
    home.packages = [pkgs.krita];
  };
}
