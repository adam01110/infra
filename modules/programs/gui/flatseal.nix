{self, ...}: {
  flake.modules.homeManager.flatseal = {
    imports = [self.modules.homeManager.flatpak];

    services.flatpak.packages = ["com.github.tchx84.Flatseal"];
  };
}
