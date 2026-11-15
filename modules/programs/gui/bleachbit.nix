{
  flake.aspects.bleachbit.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.bleachbit];
  };
}
