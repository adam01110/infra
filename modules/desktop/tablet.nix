{self, ...}: {
  flake.modules.homeManager.tablet = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      filter
      head
      mkIf
      # keep-sorted end
      ;

    monitors = config.programs.hylix.monitors or [];
    candidates =
      filter (
        monitor: (monitor.position or null) == "0x0"
      )
      monitors;
  in {
    imports = [
      {
        key = "homeManager-hyprland";
        imports = [self.modules.homeManager.hyprland];
      }
    ];

    config = mkIf (candidates != []) {
      programs.hylix.settings.input.tablet = {
        inherit ((head candidates)) output;
        transform = 0;
      };
    };
  };

  flake.modules.nixos.tablet = {
    hardware = {
      # keep-sorted start newline_separated=yes
      opentabletdriver.enable = true;

      # Required by opentabletdriver.
      uinput.enable = true;
      # keep-sorted end
    };
  };
}
