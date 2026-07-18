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
        after = ["redis-anubis.service"];
        wants = ["redis-anubis.service"];
      };

      redis-anubis = {
        after = ["sops-install-secrets.service"];
        wants = ["sops-install-secrets.service"];
      };
    };
  };
}
