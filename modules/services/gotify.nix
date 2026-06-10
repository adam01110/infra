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
    inherit
      (lib)
      # keep-sorted start
      getExe
      mkAfter
      mkForce
      # keep-sorted end
      ;

    templates = config.sops.templates;
    inherit (vars) groundDomain;
  in {
    sops = {
      secrets = {
        "gotify/client_id" = {};
        "gotify/client_secret" = {};
      };

      templates."gotify.env".content = ''
        GOTIFY_OIDC_CLIENTID=${config.sops.placeholder."gotify/client_id"}
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
      after = mkAfter [
        # keep-sorted start
        "authentik-worker.service"
        "authentik.service"
        "postgresql.service"
        "sops-install-secrets.service"
        # keep-sorted end
      ];

      requires = [
        # keep-sorted start
        "authentik-worker.service"
        "authentik.service"
        "postgresql.service"
        "sops-install-secrets.service"
        # keep-sorted end
      ];

      preStart = let
        inherit (pkgs.nur.repos.adam0) gotifyPlugins;
        inherit (config.services.gotify) stateDirectoryName;

        oidcDiscoveryUrl = "${config.services.gotify.environment.GOTIFY_OIDC_ISSUER}.well-known/openid-configuration";
        pluginDir = "/var/lib/${stateDirectoryName}/data/plugins";

        wantedPlugins = [
          # keep-sorted start block=yes newline_separated=yes
          {
            drv = gotifyPlugins.gotify-authentik-plugin;
            file = "authentik-plugin.so";
          }

          #{drv = gotifyPlugins.gotify-webhooks-plugin; file = "webhooks-plugin.so";}
          # keep-sorted end
        ];
      in ''
        ${getExe pkgs.gotify-install-plugins} ${pluginDir} ${oidcDiscoveryUrl} \
        ${builtins.concatStringsSep " " (map (p: "${p.drv}/${p.file}:${p.file}") wantedPlugins)}
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
