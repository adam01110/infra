{
  flake.modules.homeManager.sober = let
    pkg = "org.vinegarhq.Sober";
  in {
    # Install the flatpak and expose Discord IPC sockets.
    services.flatpak = {
      packages = [pkg];

      overrides.${pkg}.Context.filesystems = [
        # keep-sorted start
        "xdg-run/app/com.discordapp.Discord:create"
        "xdg-run/discord-ipc-0"
        # keep-sorted end
      ];
    };
  };
}
