{self, ...}: {
  flake.modules.homeManager.warehouse = {pkgs, ...}: {
    imports = [self.modules.homeManager.flatpak];

    home.packages = [pkgs.warehouse];
  };
}
