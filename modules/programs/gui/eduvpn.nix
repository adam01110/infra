{
  flake.aspects.eduvpn.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.eduvpn-client];
  };
}
