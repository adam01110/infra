{
  flake.modules.homeManager.noctalia = _: {
    programs.noctalia-shell.settings.dock = {
      # keep-sorted start
      backgroundOpacity = 0.95;
      colorizeIcons = false;
      displayMode = "auto_hide";
      enabled = false;
      floatingRatio = 0.5;
      onlySameOutput = true;
      size = 0.3;
      # keep-sorted end
    };
  };
}
