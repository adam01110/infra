{
  flake.modules.nixos.valkey = {
    # keep-sorted start
    config,
    pkgs,
    # keep-sorted end
    ...
  }: let
    instance = config.services.redis.servers.anubis;
    secrets = config.sops.secrets;
  in {
    sops.secrets."anubis/valkey_server_password" = {
      key = "anubis/valkey_password";
      mode = "0400";
      owner = instance.user;
      restartUnits = ["redis-anubis.service"];
    };

    services.redis = {
      package = pkgs.valkey;
      vmOverCommit = true;

      servers.anubis = {
        enable = true;

        appendOnly = true;

        bind = "10.100.0.1";
        port = 6379;
        unixSocket = null;

        requirePassFile = secrets."anubis/valkey_server_password".path;
      };
    };

    networking.firewall.interfaces.wg0.allowedTCPPorts = [6379];

    systemd.services = {
      anubis-traefik = {
        # keep-sorted start
        after = ["redis-anubis.service"];
        wants = ["redis-anubis.service"];
        # keep-sorted end
      };

      redis-anubis = {
        # keep-sorted start block=yes newline_separated=yes
        after = [
          # keep-sorted start
          "sops-install-secrets.service"
          "wireguard-wg0.service"
          # keep-sorted end
        ];

        requires = ["wireguard-wg0.service"];

        wants = ["sops-install-secrets.service"];
        # keep-sorted end
      };
    };
  };
}
