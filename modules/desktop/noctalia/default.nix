{
  # keep-sorted start
  inputs,
  self,
  # keep-sorted end
  ...
}: {
  flake-file.inputs = {
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.nixos.noctalia = {
    nixpkgs.overlays = [self.overlays.pkgs];

    nix.settings = let
      cache = "https://noctalia.cachix.org";
    in {
      substituters = [cache];
      trusted-substituters = [cache];
      trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
    };
  };

  flake.modules.homeManager.noctalia = {lib, ...}: let
    inherit (lib) mkEnableOption;
  in {
    imports = [inputs.noctalia.homeModules.default];

    options.programs.noctalia.battery.enable = mkEnableOption "battery widgets";

    config.programs.noctalia = {
      enable = true;
      systemd.enable = true;
    };
  };
}
