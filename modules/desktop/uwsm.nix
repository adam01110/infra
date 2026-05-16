_: {
  flake.modules.nixos.uwsm = {pkgs, ...}: {
    programs.uwsm.package = pkgs.uwsm.override {uuctlSupport = false;};
  };

  flake.modules.homeManager.uwsm = {config, ...}: {
    home.sessionVariables = {
      APP2UNIT_SLICES = "a=app-graphical.slice b=background-graphical.slice s=session-graphical.slice";
      APP2UNIT_TYPE = "service";
    };

    xdg.configFile."uwsm/env".source = "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";
  };
}
