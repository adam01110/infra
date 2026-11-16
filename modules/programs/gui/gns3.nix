{
  flake.aspects.gns3.nixos = {pkgs, ...}: {
    environment.systemPackages = [pkgs.gns3-gui];
  };
}
