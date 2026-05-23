{self, ...}: {
  flake.modules.homeManager.noctalia = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit (lib) mkForce;
    colors = config.lib.stylix.colors.withHashtag;
  in {
    imports = [self.modules.homeManager.stylixBase];

    stylix.targets.noctalia-shell.colors.override.withHashtag = with colors; {
      # keep-sorted start
      base05 = base06;
      base0C = base0D;
      base0D = base0B;
      base0E = base0A;
      # keep-sorted end
    };

    programs.noctalia-shell = {
      # keep-sorted start block=yes newline_separated=yes
      # System monitor colors from stylix.
      settings = {
        # keep-sorted start block=yes newline_separated=yes
        bar = {
          # keep-sorted start
          backgroundOpacity = mkForce 1.0;
          capsuleOpacity = mkForce 1.0;
          # keep-sorted end
        };

        systemMonitor = with colors; {
          # keep-sorted start
          criticalColor = base08;
          useCustomColors = true;
          warningColor = base0A;
          # keep-sorted end
        };
        # keep-sorted end

        # keep-sorted start
        dock.backgroundOpacity = mkForce 1.0;
        notifications.backgroundOpacity = mkForce 1.0;
        osd.backgroundOpacity = mkForce 1.0;
        ui.panelBackgroundOpacity = mkForce 1.0;
        # keep-sorted end
      };
      # keep-sorted end
    };
  };
}
