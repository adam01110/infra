{self, ...}: {
  flake.modules.homeManager.mcpelauncher = {
    imports = [self.modules.homeManager.flatpak];

    services.flatpak.packages = ["io.mrarm.mcpelauncher"];
  };
}
