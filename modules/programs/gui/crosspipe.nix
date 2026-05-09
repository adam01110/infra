{
  flake.modules.homeManager.crosspipe = {pkgs, ...}: {
    home.packages = [pkgs.crosspipe];
  };
}
