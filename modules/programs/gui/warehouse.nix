{
  flake.modules.homeManager.warehouse = {pkgs, ...}: {
    home.packages = [pkgs.warehouse];
  };
}
