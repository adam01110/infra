{
  flake.aspects.uwsm = {
    nixos = {pkgs, ...}: {
      programs.uwsm.package = pkgs.uwsm.override {uuctlSupport = false;};
    };

    homeManager = {config, ...}: {
      xdg.configFile."uwsm/env".source = "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";
    };
  };
}
