{
  flake.modules.nixos.hawser = {
    # keep-sorted start
    config,
    lib,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (lib) mkForce mkOption;

    inherit (vars) groundDomain;
    hostname = config.networking.hostName;
    hawserTokenSecret = "dockhand/hawser_tokens/${hostname}";
  in {
    options.services.hawser.dockhandServerUrl = mkOption {
      type = lib.types.str;
      default = "wss://dockhand.${groundDomain}/api/hawser/connect";
      description = "WebSocket URL for the dockhand server agent connection endpoint.";
    };

    config = {
      sops.secrets.${hawserTokenSecret} = {};

      sops.templates."hawser.env".content = ''
        TOKEN=${config.sops.placeholder.${hawserTokenSecret}}
      '';

      virtualisation.oci-containers.containers.hawser = {
        hostname = "hawser";
        image = "ghcr.io/finsys/hawser:latest";
        extraOptions = [
          "--network=host"

          # Health check.
          "--health-cmd=wget -q --spider http://[::1]:2376/_hawser/health || exit 1"
          "--health-interval=30s"
          "--health-retries=3"
          "--health-start-period=10s"
          "--health-timeout=5s"
        ];

        environment = {
          AGENT_NAME = hostname;
          DOCKHAND_SERVER_URL = config.services.hawser.dockhandServerUrl;
          STACKS_DIR = "/var/lib/hawser/stacks";
        };

        environmentFiles = [config.sops.templates."hawser.env".path];
        volumes = [
          "/run/podman/podman.sock:/var/run/docker.sock"
          "/var/lib/hawser/stacks:/var/lib/hawser/stacks"
        ];
      };

      systemd = {
        tmpfiles.rules = ["d /var/lib/hawser/stacks 0750 root root -"];
        services.podman-hawser.serviceConfig.TimeoutStopSec = mkForce "60s";
      };
    };
  };
}
