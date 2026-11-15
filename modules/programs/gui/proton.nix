{
  flake.aspects.proton.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.proton-vpn];
  };
}
