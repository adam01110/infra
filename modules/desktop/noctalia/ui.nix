{
  flake.modules.homeManager.noctalia = {
    programs.noctalia-shell.settings.ui = {
      # keep-sorted start
      boxBorderEnabled = true;
      fontDefaultScale = 0.8;
      fontFixedScale = 0.8;
      panelBackgroundOpacity = 0.95;
      panelsAttachedToBar = false;
      settingsPanelMode = "centered";
      # keep-sorted end
    };
  };
}
