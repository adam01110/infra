{
  flake.modules.nixos.traefik = {
    # keep-sorted start
    config,
    vars,
    # keep-sorted end
    ...
  }: let
    secrets = config.sops.secrets;

    inherit (vars) groundDomain;
  in {
    services.traefik.dynamicConfigOptions = {
      http = {
        middlewares = {
          # keep-sorted start block=yes newline_separated=yes
          anubis.forwardAuth = {
            address = "http://127.0.0.1:8923/.within.website/x/cmd/anubis/api/check";
            trustForwardHeader = true;
          };

          authentik-proxy.forwardAuth = {
            address = "http://[::1]:9005/outpost.goauthentik.io/auth/traefik";
            trustForwardHeader = true;
          };

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
            crowdsecLapiUrl = "http://127.0.0.1:8080";
            crowdsecLapiKeyFile = secrets."traefik/crowdsec_bouncer_key".path;
          };

          redirect-to-https.redirectscheme = {
            scheme = "https";
            permanent = true;
          };

          robots.headers.customResponseHeaders.X-Robots-Tag = "noindex, nofollow, noarchive, nosnippet, noimageindex";
          # keep-sorted end
        };

        routers = {
          # keep-sorted start block=yes newline_separated=yes
          anubis = {
            entryPoints = ["websecure"];
            rule = "Host(`anubis.${groundDomain}`)";
            service = "anubis";
          };

          apprise = {
            entryPoints = ["websecure"];
            middlewares = [
              "anubis@file"
              "authentik@file"
            ];
            rule = "Host(`apprise.${groundDomain}`)";
            service = "apprise";
          };

          authentik = {
            entryPoints = ["websecure"];
            middlewares = ["anubis@file"];
            rule = "Host(`authentik.${groundDomain}`)";
            service = "authentik";
          };

          authentik-outpost = {
            entryPoints = ["websecure"];
            middlewares = ["anubis@file"];
            priority = 15;
            rule = "Host(`traefik.${groundDomain}`) && PathPrefix(`/outpost.goauthentik.io/`)";
            service = "authentik-outpost";
          };

          cloudbeaver = {
            entryPoints = ["websecure"];
            middlewares = [
              "anubis@file"
              "authentik@file"
            ];
            rule = "Host(`cloudbeaver.${groundDomain}`)";
            service = "cloudbeaver";
          };

          dockhand = {
            entryPoints = ["websecure"];
            middlewares = ["anubis@file"];
            rule = "Host(`dockhand.${groundDomain}`)";
            service = "dockhand";
          };

          gotify = {
            entryPoints = ["websecure"];
            middlewares = ["anubis@file"];
            rule = "Host(`gotify.${groundDomain}`)";
            service = "gotify";
          };

          robots = {
            entryPoints = ["websecure"];
            priority = 100;
            rule = "Path(`/robots.txt`)";
            service = "anubis";
          };

          traefik-dashboard = {
            entryPoints = ["websecure"];
            middlewares = [
              "anubis@file"
              "authentik@file"
            ];
            rule = "Host(`traefik.${groundDomain}`)";
            service = "api@internal";
          };
          # keep-sorted end
        };

        services = {
          # keep-sorted start block=yes newline_separated=yes
          anubis.loadBalancer.servers = [
            {url = "http://127.0.0.1:8923";}
          ];

          apprise.loadBalancer.servers = [
            {url = "http://10.100.0.1:8000";}
          ];

          authentik-outpost.loadBalancer.servers = [
            {url = "http://[::1]:9005/outpost.goauthentik.io";}
          ];

          authentik.loadBalancer.servers = [
            {url = "http://127.0.0.1:9000";}
          ];

          cloudbeaver.loadBalancer.servers = [
            {url = "http://127.0.0.1:8978";}
          ];

          dockhand.loadBalancer.servers = [
            {url = "http://127.0.0.1:3000";}
          ];

          gotify.loadBalancer.servers = [
            {url = "http://127.0.0.1:44407";}
          ];
          # keep-sorted end
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
          {address = "[::1]:2222";}
        ];
      };
    };
  };
}
