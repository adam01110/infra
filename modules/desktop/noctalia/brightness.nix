{
  flake.modules.homeManager.noctalia = {
    programs.noctalia-shell.settings.brightness = {
      # keep-sorted start
      enableDdcSupport = true;
      enforceMinimum = false;
      # keep-sorted end
    };
  };
}
