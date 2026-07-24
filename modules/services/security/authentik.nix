{inputs, ...}: {
  flake-file.inputs.authentik-nix = {
    url = "github:nix-community/authentik-nix";
    inputs.flake-parts.follows = "flake-parts";
  };

  flake.modules.nixos.authentik = {
    # keep-sorted start
    config,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (vars) groundDomain;
  in {
    imports = [inputs.authentik-nix.nixosModules.default];

    sops = {
      secrets = {
        # keep-sorted start
        "authentik/proxy_token" = {};
        "authentik/secret_key" = {};
        # keep-sorted end

        # keep-sorted start
        "authentik/email/from" = {};
        "authentik/email/host" = {};
        "authentik/email/password" = {};
        "authentik/email/username" = {};
        # keep-sorted end
      };

      templates = {
        "authentik.env".content = ''
          AUTHENTIK_SECRET_KEY=${config.sops.placeholder."authentik/secret_key"}
          AUTHENTIK_EMAIL__HOST=${config.sops.placeholder."authentik/email/host"}
          AUTHENTIK_EMAIL__USERNAME=${config.sops.placeholder."authentik/email/username"}
          AUTHENTIK_EMAIL__PASSWORD=${config.sops.placeholder."authentik/email/password"}
          AUTHENTIK_EMAIL__FROM=${config.sops.placeholder."authentik/email/from"}
        '';

        "authentik-proxy.env".content = ''
          AUTHENTIK_HOST=https://authentik.${groundDomain}
          AUTHENTIK_TOKEN=${config.sops.placeholder."authentik/proxy_token"}
        '';
      };
    };

    services = {
      authentik = {
        enable = true;
        environmentFile = config.sops.templates."authentik.env".path;

        settings = {
          avatars = "gravatar";

          # Bind only to loopback; external access goes through Traefik.
          listen.listen_http = "127.0.0.1:9000";

          # Disable unrequired features.
          disable_startup_analytics = true;
          disable_update_check = true;
          error_reporting.enabled = false;

          email = {
            port = 465;
            use_ssl = true;
          };
        };
      };

      authentik-proxy = {
        enable = true;
        environmentFile = config.sops.templates."authentik-proxy.env".path;
      };
    };

    systemd.services.authentik-worker.serviceConfig.TimeoutStopSec = "60s";
  };
}
