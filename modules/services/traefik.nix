{
  flake.modules.nixos.traefik = {
    # keep-sorted start
    config,
    vars,
    # keep-sorted end
    ...
  }: let
    secrets = config.sops.secrets;
    templates = config.sops.templates;

    inherit (vars) groundDomain;
  in {
    sops = {
      secrets = {
        # keep-sorted start block=yes newline_separated=yes
        "traefik/crowdsec_bouncer_key" = {
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
            ssh.address = ":22";

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
              };

              transport.respondingTimeouts = {
                readTimeout = "600s";
                writeTimeout = "600s";
                idleTimeout = "600s";
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

        dynamicConfigOptions = {
          http = {
            middlewares = {
              authentik.forwardAuth = {
                address = "http://[::1]:9005/outpost.goauthentik.io/auth/traefik";
                trustForwardHeader = true;
                authResponseHeaders = [
                  # keep-sorted start
                  "X-authentik-email"
                  "X-authentik-entitlements"
                  "X-authentik-groups"
                  "X-authentik-jwt"
                  "X-authentik-meta-app"
                  "X-authentik-meta-jwks"
                  "X-authentik-meta-outpost"
                  "X-authentik-meta-provider"
                  "X-authentik-meta-version"
                  "X-authentik-name"
                  "X-authentik-uid"
                  "X-authentik-username"
                  # keep-sorted end
                ];
              };

              crowdsec.plugin.bouncer = {
                enabled = true;
                crowdsecMode = "appsec";
                crowdsecAppsecEnabled = true;
                crowdsecAppsecHost = "127.0.0.1:7424";
                crowdsecAppsecKeyFile = secrets."traefik/crowdsec_bouncer_key".path;
              };

              redirect-to-https.redirectscheme = {
                scheme = "https";
                permanent = true;
              };
            };

            routers = {
              authentik = {
                entryPoints = ["websecure"];
                rule = "Host(`authentik.${groundDomain}`)";
                service = "authentik";
              };

              authentik-outpost = {
                entryPoints = ["websecure"];
                priority = 15;
                rule = "PathPrefix(`/outpost.goauthentik.io/`)";
                service = "authentik-outpost";
              };

              traefik-dashboard = {
                entryPoints = ["websecure"];
                middlewares = ["authentik@file"];
                rule = "Host(`traefik.${groundDomain}`)";
                service = "api@internal";
              };
            };

            services = {
              authentik.loadBalancer.servers = [
                {url = "http://[::1]:9000";}
              ];

              authentik-outpost.loadBalancer.servers = [
                {url = "http://[::1]:9005/outpost.goauthentik.io";}
              ];
            };
          };

          tcp = {
            routers.ssh-euclid = {
              entryPoints = ["ssh"];
              rule = "HostSNI(`euclid.${groundDomain}`)";
              service = "ssh-euclid";
              tls.certResolver = "myresolver";
            };

            services.ssh-euclid.loadBalancer.servers = [
              {address = "127.0.0.1:2222";}
            ];
          };
        };
      };
      # keep-sorted end
    };

    networking.firewall.allowedTCPPorts = [
      # keep-sorted start numeric=yes
      22
      80
      443
      # keep-sorted end
    ];

    systemd.tmpfiles.rules = [
      "d /var/log/traefik 0750 traefik traefik -"
    ];

    systemd.services.traefik.serviceConfig.TimeoutStopSec = "60s";
  };
}
