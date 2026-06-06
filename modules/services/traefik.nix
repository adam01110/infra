{
  flake.modules.nixos.traefik = {config, ...}: let
    secrets = config.sops.secrets;
    templates = config.sops.templates;
  in {
    sops = {
      secrets = {
        # keep-sorted start block=yes newline_separated=yes
        "traefik/crowdsec_bouncer_key" = {
          owner = "traefik";
          mode = "0400";
        };

        "traefik/redis_crowdsec_password" = {
          owner = "traefik";
          mode = "0400";
        };

        "traefik/mail" = {};
        # keep-sorted end
      };

      templates."traefik.env".content = ''
        TRAEFIK_ACME_EMAIL=${config.sops.placeholder."traefik/mail"}
      '';
    };

    services = {
      # keep-sorted start block=yes newline_separated=yes
      redis.servers.traefik-crowdsec = {
        enable = true;
        bind = "127.0.0.1";
        port = 6379;
        databases = 1;
        maxclients = 64;
        save = [];
        requirePassFile = secrets."traefik/redis_crowdsec_password".path;
      };

      traefik = {
        enable = true;
        group = "podman";
        environmentFiles = [templates."traefik.env".path];

        staticConfigOptions = {
          # keep-sorted start block=yes newline_separated=yes
          accessLog.filePath = "/var/log/traefik/access.log";

          api = {
            dashboard = true;
            insecure = false;
          };

          certificatesResolvers.myresolver.acme = {
            tlsChallenge = true;
            email = "\${TRAEFIK_ACME_EMAIL}";
            storage = "/var/lib/traefik/acme.json";
          };

          entryPoints = {
            # keep-sorted start block=yes newline_separated=yes
            web = {
              address = ":80";

              http = {
                middlewares = ["crowdsec@file"];

                redirections.entryPoint = {
                  to = "websecure";
                  scheme = "https";
                };
              };
            };

            websecure = {
              address = ":443";

              http = {
                tls.certResolver = "myresolver";
                middlewares = ["crowdsec@file"];

                transport.respondingTimeouts = {
                  readTimeout = "600s";
                  writeTimeout = "600s";
                  idleTimeout = "600s";
                };
              };
            };
            # keep-sorted end
          };

          experimental.plugins.bouncer = {
            moduleName = "github.com/maxlerebourg/crowdsec-bouncer-traefik-plugin";
            version = "v1.6.0";
          };

          log = {
            level = "INFO";
            filePath = "/var/log/traefik/traefik.log";
          };

          providers.docker = {
            endpoint = "unix:///run/podman/podman.sock";
            exposedByDefault = false;
            network = "network";
          };
          # keep-sorted end
        };

        dynamicConfigOptions.http.middlewares = {
          redirect-to-https.redirectscheme = {
            scheme = "https";
            permanent = true;
          };

          crowdsec.plugin.bouncer = {
            enabled = true;
            crowdsecMode = "stream";
            crowdsecLapiHost = "127.0.0.1:8080";
            crowdsecLapiKeyFile = secrets."traefik/crowdsec_bouncer_key".path;

            crowdsecAppsecEnabled = true;
            crowdsecAppsecHost = "127.0.0.1:7424";
            crowdsecAppsecKeyFile = secrets."traefik/crowdsec_bouncer_key".path;

            redisCacheEnabled = true;
            redisCacheHost = "127.0.0.1:6379";
            redisCachePasswordFile = secrets."traefik/redis_crowdsec_password".path;
            redisCacheDatabase = "0";
          };
        };
      };
      # keep-sorted end
    };

    networking.firewall.allowedTCPPorts = [
      # keep-sorted start numeric=yes
      80
      443
      # keep-sorted end
    ];
  };
}
