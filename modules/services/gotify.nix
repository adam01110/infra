{
  flake.modules.nixos.gotify = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (lib) mkForce;

    templates = config.sops.templates;
    inherit (vars) groundDomain;
  in {
    sops = {
      secrets = {
        "gotify/client_id" = {};
        "gotify/client_secret" = {};
      };

      templates."gotify.env".content = ''
        GOTIFY_OIDC_CLIENTID = ${config.sops.placeholder."gotify/client_id"}
        GOTIFY_OIDC_CLIENTSECRET=${config.sops.placeholder."gotify/client_secret"}
      '';
    };

    services.gotify = {
      enable = true;
      package = pkgs.nur.repos.adam0.gotify-server;
      stateDirectoryName = "gotify";

      environment = {
        GOTIFY_SERVER_PORT = 44407;
        GOTIFY_SERVER_SECURECOOKIE = "true";

        GOTIFY_OIDC_ENABLED = "true";
        GOTIFY_OIDC_ISSUER = "https://authentik.${groundDomain}/application/o/gotify/";
        GOTIFY_OIDC_REDIRECTURL = "https://gotify.${groundDomain}/auth/oidc/callback";

        GOTIFY_DATABASE_DIALECT = "postgres";
        GOTIFY_DATABASE_CONNECTION = "host=/run/postgresql user=gotify dbname=gotify sslmode=disable";
      };

      environmentFiles = [templates."gotify.env".path];
    };

    users = {
      groups.gotify = {};

      users.gotify = {
        group = "gotify";
        isSystemUser = true;
      };
    };

    systemd.services.gotify-server = {
      after = [
        "authentik-worker.service"
        "authentik.service"
        "postgresql.service"
      ];
      requires = [
        "authentik-worker.service"
        "authentik.service"
        "postgresql.service"
      ];

      preStart = let
        inherit (pkgs.nur.repos.adam0) gotifyPlugins;
        inherit (config.services.gotify) stateDirectoryName;
      in ''
        install -Dm755 ${gotifyPlugins.gotify-authentik-plugin}/authentik-plugin.so /var/lib/${stateDirectoryName}/data/plugins/authentik-plugin.so
        install -Dm755 ${gotifyPlugins.gotify-webhooks-plugin}/webhooks-plugin.so /var/lib/${stateDirectoryName}/data/plugins/webhooks-plugin.so
        chown gotify:gotify /var/lib/gotify/data/plugins/*.so
      '';

      serviceConfig = {
        DynamicUser = mkForce false;
        User = "gotify";
        Group = "gotify";
      };
    };

    systemd.services.gotify-optimize-images = {
      description = "Optimize Gotify uploaded images";

      after = ["gotify-server.service"];
      requires = ["gotify-server.service"];

      serviceConfig = {
        Type = "oneshot";
        User = "gotify";
        Group = "gotify";
        ExecStart = "${pkgs.gotify-optimize-images}/bin/gotify-optimize-images";
      };
    };

    systemd.timers.gotify-optimize-images = {
      description = "Daily Gotify image optimization";

      wantedBy = ["timers.target"];

      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };
  };
}
