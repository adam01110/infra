{
  flake.modules.homeManager.bleachbit = {pkgs, ...}: {
    home.packages = [pkgs.bleachbit];
  };
}
