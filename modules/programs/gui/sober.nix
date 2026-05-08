{self, ...}: {
  flake.modules.homeManager.sober = _: let
    pkg = "org.vinegarhq.Sober";
  in {
    imports = [self.modules.homeManager.flatpak];

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
