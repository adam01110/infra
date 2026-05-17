{inputs, ...}: {
  flake-file.inputs = {
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell?ref=v4.7.7";
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

    # Expose an enable toggle for battery widgets.
    options.programs.noctalia-shell.battery.enable = mkEnableOption "Enable the battery service & widgets.";

    # Enable the Noctalia shell and wire up its package.
    config.programs.noctalia-shell = {
      enable = true;
      systemd.enable = true;

      # keep-sorted start block=yes newline_separated=yes
      # Enable calendar support in the flake-provided Noctalia build.
      packageOverrides.calendarSupport = true;

      # Use the current theming schema.
      settings.templates.enableUserTheming = false;
      # keep-sorted end
    };
  };
}
