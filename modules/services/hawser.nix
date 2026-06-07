{
  flake.modules.nixos.hawser = {
    # keep-sorted start
    config,
    lib,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (lib) mkForce;

    inherit (vars) groundDomain;
    hostname = config.networking.hostName;
    hawserTokenSecret = "dockhand/hawser_tokens/${hostname}";
  in {
    sops = {
      secrets.${hawserTokenSecret} = {};

      templates."hawser.env".content = ''
        DOCKHAND_TOKEN=${config.sops.placeholder.${hawserTokenSecret}}
      '';
    };

    virtualisation.oci-containers.containers.hawser = {
      hostname = "hawser";
      image = "fnsys/hawser:latest";
      extraOptions = ["--network=host"];

      environment = {
        DOCKHAND_SERVER_URL = "https://dockhand.${groundDomain}";
        HAWSER_AGENT_NAME = hostname;
      };

      environmentFiles = [config.sops.templates."hawser.env".path];
      volumes = ["/run/podman/podman.sock:/var/run/docker.sock"];
    };

    systemd.services.podman-hawser.serviceConfig.TimeoutStopSec = mkForce "60s";
  };
}
