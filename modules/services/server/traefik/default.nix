{
  flake.modules.nixos.traefik = {config, ...}: let
    templates = config.sops.templates;
  in {
    sops = {
      secrets = {
        # keep-sorted start block=yes newline_separated=yes
        "traefik/crowdsec_bouncer_key" = {
          owner = "traefik";
          mode = "0400";
        };

        "traefik/mail" = {};

        "traefik/porkbun_api_key" = {};

        "traefik/porkbun_secret_api_key" = {};
        # keep-sorted end
      };

      templates."traefik.env".content = ''
        TRAEFIK_ACME_EMAIL=${config.sops.placeholder."traefik/mail"}
        PORKBUN_API_KEY=${config.sops.placeholder."traefik/porkbun_api_key"}
        PORKBUN_SECRET_API_KEY=${config.sops.placeholder."traefik/porkbun_secret_api_key"}
      '';
    };

    services.traefik = {
      # keep-sorted start block=yes newline_separated=yes
      enable = true;

      environmentFiles = [templates."traefik.env".path];

      group = "podman";
      # keep-sorted end
    };

    networking.firewall.allowedTCPPorts = [
      # keep-sorted start numeric=yes
      22
      80
      443
      # keep-sorted end
    ];

    systemd = {
      tmpfiles.rules = ["d /var/log/traefik 0750 traefik traefik -"];

      services.traefik = {
        after = [
          # keep-sorted start
          "anubis-traefik.service"
          "podman.socket"
          # keep-sorted end
        ];
        wants = [
          # keep-sorted start
          "anubis-traefik.service"
          "podman.socket"
          # keep-sorted end
        ];

        serviceConfig.TimeoutStopSec = "60s";
        stopIfChanged = false;
      };
    };
  };
}
