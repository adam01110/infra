{
  flake.modules.nixos.computerUseLinux = {vars, ...}: {
    services.gnome.at-spi2-core.enable = true;
    users.users.${vars.username}.extraGroups = ["input"];
  };

  flake.modules.homeManager.pi = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe';
  in {
    dconf.settings."org/gnome/desktop/interface".toolkit-accessibility = true;

    home.packages = [pkgs.ydotool];

    programs.pi.coding-agent.extensions = ["npm:@agent-sh/computer-use-linux@0.4.7"];

    systemd.user.services.ydotoold = {
      Unit = {
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };

      Service = {
        ExecStart = "${getExe' pkgs.ydotool "ydotoold"} --socket-path=%t/.ydotool_socket --socket-perm=0600";
        Restart = "on-failure";
      };

      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
