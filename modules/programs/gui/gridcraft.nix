{
  flake.modules.homeManager.gridcraft = {pkgs, ...}: {
    home.packages = [pkgs.gridcraft];
  };
}
