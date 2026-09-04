{
  flake.modules.nixos.traefik = {vars, ...}: let
    inherit (vars) groundDomain;
  in {
    services.traefik.staticConfigOptions = {
      # keep-sorted start block=yes newline_separated=yes
      accessLog.filePath = "/var/log/traefik/access.log";

      api = {
        dashboard = true;
        insecure = false;
      };

      certificatesResolvers.myresolver.acme = {
        dnsChallenge.provider = "porkbun";
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
            tls = {
              certResolver = "myresolver";

              domains = [
                {
                  main = groundDomain;
                  sans = ["*.${groundDomain}"];
                }
              ];
            };

            middlewares = [
              "crowdsec@file"
              "robots@file"
            ];
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
  };
}
