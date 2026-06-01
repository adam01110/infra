{self, ...}: {
  flake-file.inputs = {
    hyprland.url = "github:hyprwm/Hyprland?ref=v0.55.2";

    hylix = {
      url = "github:adam01110/hylix";
      inputs = {
        # keep-sorted start
        flake-parts.follows = "flake-parts";
        import-tree.follows = "import-tree";
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
        # keep-sorted end
      };
    };
  };

  flake.modules.nixos.hyprland = {
    # keep-sorted start
    inputs,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (pkgs.stdenv.hostPlatform) system;

    pkgs-unstable = inputs.hyprland.inputs.nixpkgs.legacyPackages.${system};
  in {
    nixpkgs.overlays = with self.overlays; [
      hyprland
      hyprland-plugins
    ];

    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    hardware.graphics = {
      enable32Bit = true;

      package = pkgs-unstable.mesa;
      package32 = pkgs-unstable.pkgsi686Linux.mesa;
    };
  };

  flake.modules.homeManager.hyprland = {
    # keep-sorted start
    inputs,
    self,
    # keep-sorted end
    ...
  }: {
    imports = [
      # keep-sorted start
      inputs.hylix.homeManagerModules.default
      self.modules.homeManager.uwsm
      # keep-sorted end
    ];

    config = {
      wayland.windowManager.hyprland = {
        enable = true;

        # Packages are null because its installed sytem wide.
        package = null;
        portalPackage = null;
      };

      programs.hylix.enable = true;
    };
  };
}
