{
  # keep-sorted start
  inputs,
  self,
  # keep-sorted end
  ...
}: {
  flake-file.inputs = {
    noctalia = {
      url = "github:noctalia-dev/noctalia?ref=legacy-v4";
      inputs = {
        # keep-sorted start
        nixpkgs.follows = "nixpkgs";
        noctalia-qs.follows = "noctalia-qs";
        # keep-sorted end
      };
    };

    noctalia-qs = {
      url = "github:noctalia-dev/noctalia-qs";
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

    options.programs.noctalia-shell.battery.enable = mkEnableOption "Enable the battery service & widgets.";

    config.programs.noctalia-shell = {
      enable = true;
      systemd.enable = true;

      # keep-sorted start block=yes newline_separated=yes
      packageOverrides.calendarSupport = true;

      settings.templates.enableUserTheming = false;
      # keep-sorted end
    };
  };
}
