{
  flake.modules.homeManager.noctalia = {
    # keep-sorted start
    lib,
    osConfig,
    # keep-sorted end
    ...
  }: let
    inherit (lib) mkForce;
    colors = osConfig.lib.stylix.colors.withHashtag;
  in {
    programs.noctalia-shell = {
      # keep-sorted start block=yes newline_separated=yes
      # Write the noctalia color palette to a json file.
      colors = with colors; {
        # keep-sorted start
        mHover = mkForce base0D;
        mOnSurface = mkForce base06;
        mPrimary = mkForce base0B;
        mSecondary = mkForce base0A;
        mTertiary = mkForce base0D;
        # keep-sorted end
      };

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
