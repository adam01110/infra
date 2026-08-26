{self, ...}: {
  flake-file.inputs = {
    hyprland.url = "github:hyprwm/Hyprland?ref=v0.56.2";

    hylix = {
      url = "git+ssh://git@knot.zezura.xyz/did:plc:r3tmbeocrgryca5nbgxns4yu";
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
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;
    inherit (pkgs) writeShellApplication;
    inherit (pkgs.stdenv.hostPlatform) system;

    pkgs-unstable = inputs.hyprland.inputs.nixpkgs.legacyPackages.${system};

    resetTouchpad = writeShellApplication {
      name = "reset-touchpad";
      text = ''
        device=i2c-FTCS1000:00
        driver=/sys/bus/i2c/drivers/i2c_hid_acpi

        test -L "$driver/$device"
        printf %s "$device" >"$driver/unbind"
        sleep 0.5
        printf %s "$device" >"$driver/bind"
      '';
    };
  in {
    nixpkgs.overlays = with self.overlays; [
      # keep-sorted start
      hyprland
      hyprland-plugins
      # keep-sorted end
    ];

    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    systemd.services.touchpad-reset = {
      description = "Reset the I2C touchpad driver";

      serviceConfig = {
        ExecStart = getExe resetTouchpad;
        Type = "oneshot";
      };
    };

    hardware.graphics = {
      enable32Bit = true;

      package = pkgs-unstable.mesa;
      package32 = pkgs-unstable.pkgsi686Linux.mesa;
    };
  };

  flake.modules.homeManager.hyprland = {inputs, ...}: {
    imports = [inputs.hylix.homeManagerModules.default];

    config = {
      wayland.windowManager.hyprland = {
        enable = true;

        # UWSM manages the graphical session target.
        systemd.enable = false;

        # Packages are null because its installed sytem wide.
        package = null;
        portalPackage = null;

        xdph.settings.screencopy.max_fps = 60;
      };

      programs.hylix.enable = true;
    };
  };
}
