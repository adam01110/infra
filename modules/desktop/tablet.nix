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
      attrNames
      filter
      head
      mkIf
      # keep-sorted end
      ;

    monitors = config.hyprland.monitors or {};
    candidates = filter (
      name: (monitors.${name}.position or null) == "0x0"
    ) (attrNames monitors);
  in {
    imports = [self.modules.homeManager.hyprland];

    config = mkIf (candidates != []) {
      programs.nixhypr.devices = [
        {
          name = "opentabletdriver-virtual-artist-tablet";
          output = head candidates;
          transform = 0;
        }
      ];
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
