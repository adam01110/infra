{
  flake.modules.homeManager.cava = {
    programs.cava = {
      enable = true;

      settings = {
        # keep-sorted start block=yes newline_separated=yes
        general = {
          # keep-sorted start
          bar_spacing = 2;
          bar_width = 1;
          # keep-sorted end
        };

        # Use pulseaudio as input as pipewire doesnt work on pc?
        input.method = "pulse";

        smoothing = {
          # keep-sorted start
          monstercat = 1;
          noise_reduction = 33;
          # keep-sorted end
        };
        # keep-sorted end
      };
    };

    stylix.targets.cava.rainbow.enable = true;
  };
}
