{
  flake.modules = {
    nixos.computerUseLinux = {vars, ...}: {
      services.gnome.at-spi2-core.enable = true;
      users.users.${vars.username}.extraGroups = ["input"];
    };

    homeManager.pi = {
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

      systemd.user.services.ydotoold = {
        Unit = {
          # keep-sorted start
          After = ["graphical-session.target"];
          PartOf = ["graphical-session.target"];
          # keep-sorted end
        };

        Service = {
          ExecStart = "${getExe' pkgs.ydotool "ydotoold"} --socket-path=%t/.ydotool_socket --socket-perm=0600";
          Restart = "on-failure";
        };

        Install.WantedBy = ["graphical-session.target"];
      };
    };
  };
}
