{
  flake.modules.nixos.laptop = {
    # keep-sorted start
    self,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (vars) username;
  in {
    home-manager.users.${username} = {
      imports = with self.modules.homeManager; [
        # keep-sorted start
        personal
        # keep-sorted end
      ];

      # keep-sorted start block=yes newline_separated=yes
      # Enable laptop hardware features.
      programs.nixcord.equibop.camera.enable = true;

      # Enable laptop-specific hyprland features.
      programs.nixhypr = {
        # keep-sorted start block=yes newline_separated=yes
        monitors = [
          {
            output = "eDP-1";
            mode = "1920x1080@60";
            position = "0x0";
            scale = "1";
          }
        ];

        touch.enable = true;
        # keep-sorted end
      };

      # Enable laptop-specific noctalia features.
      programs.noctalia-shell = {
        battery.enable = true;
        idle = {
          # keep-sorted start
          brightness.enable = true;
          suspend.enable = true;
          # keep-sorted end
        };
      };

      # Gpu monitoring for intel integrated graphics.
      programs.nvtop.types = ["intel"];

      # Travel mode configuration for mobile usage.
      programs.zen-browser.profiles.default.preferences = {
        # keep-sorted start
        commitSpace = 13107;
        travel.enable = true;
        # keep-sorted end
      };
      # keep-sorted end
    };
  };
}
