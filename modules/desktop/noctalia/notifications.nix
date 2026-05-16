{
  flake.modules.homeManager.noctalia = _: {
    programs.noctalia-shell.settings.notifications = {
      # keep-sorted start
      criticalUrgencyDuration = 8;
      enableKeyboardLayoutToast = false;
      lowUrgencyDuration = 2;
      normalUrgencyDuration = 4;
      respectExpireTimeout = false;
      # keep-sorted end
    };
  };
}
