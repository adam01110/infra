{
  flake.modules.homeManager.upscayl = {pkgs, ...}: {
    home.packages = [pkgs.upscayl];
  };
}
