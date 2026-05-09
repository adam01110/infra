{
  flake.modules.homeManager.proton = {pkgs, ...}: {
    home.packages = [pkgs.proton-vpn];
  };
}
