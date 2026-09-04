{
  flake.modules.nixos.hawser = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      mkForce
      mkOption
      types
      # keep-sorted end
      ;

    hostname = config.networking.hostName;
    hawserTokenSecret = "dockhand/hawser_tokens/${hostname}";
  in {
    options.services.hawser.dockhandServerUrl = mkOption {
      type = types.str;
      default = "ws://10.100.0.1:3000/api/hawser/connect";
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
        labels."io.containers.autoupdate" = "registry";

        extraOptions = [
          "--cgroupns=host"
          "--network=host"
          "--pid=host"

          # Health check.
          "--health-cmd=wget -q --spider http://[::1]:2376/_hawser/health || exit 1"
          "--health-interval=60s"
          "--health-retries=5"
          "--health-start-period=30s"
          "--health-timeout=5s"
        ];

        environment = {
          AGENT_NAME = hostname;
          DOCKHAND_SERVER_URL = config.services.hawser.dockhandServerUrl;
        };

        environmentFiles = [config.sops.templates."hawser.env".path];

        volumes = [
          "/var/lib/hawser:/data/stacks"
          "/run/podman/podman.sock:/var/run/docker.sock"
        ];
      };

      systemd = {
        tmpfiles.rules = ["d /var/lib/hawser 0750 root root -"];
        services.podman-hawser.serviceConfig.TimeoutStopSec = mkForce "60s";
      };
    };
  };
}
