{
  flake.modules.homeManager.aseprite = {pkgs, ...}: {
    home.packages = [pkgs.aseprite];
  };
}
