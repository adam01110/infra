{
  flake.modules.homeManager.hyfetch = {
    programs.hyfetch = {
      enable = true;

      settings = {
        # Required fields have no deserialization defaults in HyFetch 2.1.
        # keep-sorted start
        auto_detect_light_dark = true;
        backend = "fastfetch";
        color_align.mode = "horizontal";
        mode = "rgb";
        preset = "gay-men";
        pride_month_disable = false;
        # keep-sorted end
      };
    };
  };
}
