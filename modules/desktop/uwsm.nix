{
  flake.modules = {
    nixos.uwsm = {pkgs, ...}: {
      programs.uwsm.package = pkgs.uwsm.override {uuctlSupport = false;};
    };

    homeManager.uwsm = {config, ...}: {
      xdg.configFile."uwsm/env".source = "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";
    };
  };
}
