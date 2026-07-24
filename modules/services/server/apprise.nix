{
  flake.modules.nixos.apprise = {
    virtualisation.oci-containers.containers.apprise = {
      hostname = "apprise";
      image = "caronc/apprise:latest";

      environment = {
        APPRISE_ADMIN = "y";
        APPRISE_STATEFUL_MODE = "simple";
        APPRISE_WORKER_COUNT = "1";
        APPRISE_WORKER_MAX_REQUESTS = "200";
      };

      extraOptions = [
        # Publish on WireGuard only; containers route via wg0.
        "--publish=10.100.0.1:8000:8000"
        "--tmpfs=/tmp"
        "--user=1000:1000"

        # Health check.
        "--health-cmd=curl -fsSo /dev/null http://127.0.0.1:8000/ || exit 1"
        "--health-interval=60s"
        "--health-retries=5"
        "--health-start-period=30s"
        "--health-timeout=5s"
      ];

      volumes = [
        # keep-sorted start
        "/var/lib/apprise/attach:/attach"
        "/var/lib/apprise/config:/config"
        "/var/lib/apprise/plugin:/plugin"
        # keep-sorted end
      ];
    };

    networking.firewall.extraInputRules = ''
      # Allow containers to reach host Apprise API.
      iifname "podman*" tcp dport 8000 accept
    '';

    systemd.tmpfiles.rules = [
      # keep-sorted start
      "d /var/lib/apprise 0750 1000 1000 -"
      "d /var/lib/apprise/attach 0750 1000 1000 -"
      "d /var/lib/apprise/config 0750 1000 1000 -"
      "d /var/lib/apprise/plugin 0750 1000 1000 -"
      # keep-sorted end
    ];

    # Published address exists only after wg0 is up.
    systemd.services.podman-apprise = {
      after = ["wireguard-wg0.service"];
      wants = ["wireguard-wg0.service"];
    };
  };
}
