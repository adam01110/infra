{
  flake.aspects.sunshine = {
    nixos = {
      services.sunshine = {
        enable = true;
        # Start on demand with `systemctl --user start sunshine`.
        autoStart = false;
        # Allow Moonlight clients on the local network to connect.
        openFirewall = true;
        # Grant CAP_SYS_ADMIN for KMS capture under Wayland.
        capSysAdmin = true;
      };

      # Load uhid at boot so udev grants seat access for virtual DualSense pads.
      boot.kernelModules = ["uhid"];
    };

    homeManager = {
      # keep-sorted start
      lib,
      osConfig,
      # keep-sorted end
      ...
    }: let
      inherit
        (lib)
        # keep-sorted start
        escapeRegex
        getExe'
        # keep-sorted end
        ;
    in {
      # Skip the Hyprland screencopy prompt; the launcher script execs the hidden wrapped binary.
      programs.hylix.permissions = [
        {
          binary = escapeRegex (getExe' osConfig.services.sunshine.package ".sunshine-wrapped");
          mode = "allow";
          type = "screencopy";
        }
      ];
    };
  };
}
