{self, ...}: {
  flake.modules.homeManager.opencubicplayer = {pkgs, ...}: {
    imports = [self.modules.homeManager.nur];

    home.packages = [pkgs.nur.repos.adam0.opencubicplayer];
  };
}
