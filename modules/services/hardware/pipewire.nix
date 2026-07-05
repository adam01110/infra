{
  flake.modules.nixos.pipewire = {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;

      # keep-sorted start
      alsa.enable = true;
      jack.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
      # keep-sorted end

      # Keep 32-bit audio.
      alsa.support32Bit = true;
    };
  };
}
