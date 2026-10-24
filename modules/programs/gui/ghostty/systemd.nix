{
  flake.modules.homeManager.ghostty = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe' mkIf;
  in {
    xdg.configFile."systemd/user/app-com.mitchellh.ghostty.service.d/startup.conf" = mkIf config.programs.ghostty.systemd.enable {
      # Avoid Ghostty 1.3.1 announcing readiness before installing its reload handler.
      text = ''
        [Service]
        Type=dbus
        ExecReload=${getExe' pkgs.coreutils "kill"} -USR2 $MAINPID
      '';
    };
  };
}
