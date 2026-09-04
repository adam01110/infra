{
  flake.modules.homeManager.mangohud.programs.mangohud = {
    enable = true;

    settings = {
      # keep-sorted start
      fps = true;
      frame_timing = true;
      horizontal = true;
      horizontal_stretch = 0;
      legacy_layout = false;
      position = "top-left";
      # keep-sorted end
    };
  };
}
