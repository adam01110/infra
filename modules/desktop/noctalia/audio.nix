{
  flake.modules.homeManager.noctalia = {
    programs.noctalia-shell.settings.audio = {
      # keep-sorted start
      cavaFrameRate = 60;
      visualizerType = "mirrored";
      volumeOverdrive = true;
      # keep-sorted end
    };
  };
}
