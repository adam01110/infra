{
  flake.aspects.gen-license.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.gen-license];
  };
}
