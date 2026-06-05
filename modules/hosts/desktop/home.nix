{
  flake.modules.nixos.desktop = {
    # keep-sorted start
    lib,
    self,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (lib) mkForce;

    inherit (vars) username;
  in {
    home-manager.users.${username} = {
      imports = with self.modules.homeManager; [
        # Profiles
        # keep-sorted start
        gaming
        personal
        # keep-sorted end
      ];

      programs = {
        # keep-sorted start block=yes newline_separated=yes
        # Enable rocm gpu backend for system monitoring.
        btop.gpuBackends = ["rocm"];

        # Configure dual monitor setup.
        hylix.monitors = [
          {
            output = "DP-1";
            mode = "1920x1080@144";
            position = "-1920x96";
            scale = "1";
            extra.vrr = 0;
          }

          {
            output = "DP-2";
            mode = "2560x1440@170";
            position = "0x0";
            scale = "1";
          }
        ];

        noctalia-shell = {
          # keep-sorted start newline_separated=yes
          # Keep the desktop weather location in sops.
          location.source = "sops";

          # Avoid desktop suspend after idle blanking.
          settings.idle.suspendTimeout = mkForce 0;

          # Enable gpu acceleration for noctalia.
          systemMonitor.enableGpu = true;
          # keep-sorted end
        };

        # Gpu monitoring support for multi-gpu desktop.
        nvtop.types = [
          # keep-sorted start
          "amd"
          "intel"
          # keep-sorted end
        ];

        # Browser memory allocation for desktop usage.
        zen-browser.profiles.default.preferences.commitSpace = 25698;
        # keep-sorted end
      };
    };
  };
}
