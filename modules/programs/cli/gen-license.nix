{
  flake.modules.homeManager.gen-license = {pkgs, ...}: {
    home.packages = [pkgs.gen-license];
  };
}
