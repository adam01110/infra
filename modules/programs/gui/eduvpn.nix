{
  flake.modules.homeManager.eduvpn = {pkgs, ...}: {
    home.packages = [pkgs.eduvpn-client];
  };
}
