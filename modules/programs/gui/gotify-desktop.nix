{
  flake.modules.homeManager.gotify-desktop = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;

    tomlFormat = pkgs.formats.toml {};

    inherit (vars) groundDomain;
  in {
    sops.secrets."gotify/desktop_token" = {};

    home.packages = [pkgs.gotify-desktop];

    # keep-sorted start block=yes newline_separated=yes
    systemd.user.services.gotify-desktop = {
      Unit = {
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };

      Service = {
        ExecStart = getExe pkgs.gotify-desktop;
        Restart = "always";
        RestartSec = 5;
      };

      Install.WantedBy = ["graphical-session.target"];
    };

    xdg.configFile."gotify-desktop/config.toml".source = tomlFormat.generate "gotify-desktop-config.toml" {
      gotify = {
        auto_delete = false;
        token.command = "cat ${config.sops.secrets."gotify/desktop_token".path}";
        url = "wss://gotify.${groundDomain}";
      };

      notification.min_priority = 0;
    };
    # keep-sorted end
  };
}
