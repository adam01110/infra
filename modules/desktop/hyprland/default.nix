{
  flake-file.inputs = {
    hylix = {
      url = "git+https://tangled.org/did:plc:r3tmbeocrgryca5nbgxns4yu";
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

  flake.modules = {
    nixos.hyprland = {
      # keep-sorted start
      lib,
      pkgs,
      # keep-sorted end
      ...
    }: let
      inherit (lib) getExe;
      inherit (pkgs) writeShellApplication;

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
      };
    };

    homeManager.hyprland = {inputs, ...}: {
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
  };
}
