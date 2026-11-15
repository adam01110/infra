{
  flake.aspects.pipewire.nixos = {config, ...}: {
    security.rtkit.enable = true;

    # Provide pw-jack for JACK clients instead of a global LD_LIBRARY_PATH.
    environment.systemPackages = [config.services.pipewire.package.jack];

    services.pipewire = {
      enable = true;

      # keep-sorted start
      alsa.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
      # keep-sorted end

      # Keep 32-bit audio.
      alsa.support32Bit = true;

      # The X11 bell module segfaults when Xwayland exits at logout.
      extraConfig.pipewire."99-no-x11-bell"."context.properties"."module.x11.bell" = false;
    };
  };
}
