{
  flake.modules.homeManager.discord = _: {
    programs.nixcord = {
      # Write main equibop configuration.
      config = {
        # keep-sorted start
        autoUpdate = true;
        frameless = true;
        transparent = true;
        # keep-sorted end
      };

      equibop.settings = {
        discordBranch = "stable";

        # keep-sorted start
        arRPC = true;
        autoStartMinimized = true;
        clickTrayToShowHide = true;
        customTitleBar = false;
        hardwareVideoAcceleration = true;
        minimizeToTray = true;
        splashProgress = true;
        # keep-sorted end
      };
    };
  };
}
