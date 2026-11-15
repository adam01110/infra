{
  flake.aspects.laptop.homeManager = {
    programs = {
      # keep-sorted start block=yes newline_separated=yes
      # Laptop display and touch controls.
      hylix = {
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

      nixcord.equibop.camera.enable = true;

      # Laptop battery and idle controls.
      noctalia = {
        battery.enable = true;
        idle = {
          # keep-sorted start
          brightness.enable = true;
          suspend.enable = true;
          # keep-sorted end
        };
      };

      nvtop.types = ["intel"];

      # Travel mode configuration for mobile usage.
      zen-browser.profiles.default.preferences = {
        # keep-sorted start
        commitSpace = 13107;
        travel.enable = true;
        # keep-sorted end
      };
      # keep-sorted end
    };
  };
}
