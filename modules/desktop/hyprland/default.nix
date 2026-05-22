{self, ...}: {
  flake-file.inputs = {
    hyprland.url = "github:hyprwm/Hyprland?ref=v0.55.2";

    nixhypr = {
      url = "github:karol-broda/nixhypr";
      inputs = {
        # keep-sorted start
        hyprland.follows = "hyprland";
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
    imports = [self.modules.nixos.uwsm];

    nixpkgs.overlays = [self.overlays.hyprland];

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
    config,
    inputs,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      concatStringsSep
      mkOption
      types
      # keep-sorted end
      ;

    cfg = config.programs.nixhypr;
  in {
    imports = [
      # keep-sorted start
      inputs.nixhypr.homeManagerModules.default
      self.modules.homeManager.uwsm
      # keep-sorted end
    ];

    options.programs.nixhypr = {
      extraLuaSnippets = mkOption {
        description = "Lua snippets concatenated into nixhypr's extraLua.";

        type = types.listOf types.lines;
        default = [];
      };
    };

    config = {
      wayland.windowManager.hyprland = {
        enable = true;

        # Packages are null because its installed sytem wide.
        package = null;
        portalPackage = null;
      };

      programs.nixhypr = {
        enable = true;
        extraLua = concatStringsSep "\n" cfg.extraLuaSnippets;
      };
    };
  };
}
