{
  flake.modules.nixos.postgres = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) mkForce;
  in {
    services.postgresql = {
      enable = true;
      enableTCPIP = true;

      package = pkgs.postgresql_18;

      settings = {
        # TODO: Revisit database exposure once the access model is decided.
        listen_addresses = mkForce "127.0.0.1,::1";

        shared_buffers = "256MB";
        maintenance_work_mem = "128MB";
        log_connections = true;
        log_disconnections = true;
        log_min_duration_statement = 1000;
      };

      ensureDatabases = [
        # keep-sorted start
        "crowdsec"
        "dockhand"
        # keep-sorted end
      ];

      ensureUsers = [
        # keep-sorted start block=yes newline_separated=yes
        {
          ensureDBOwnership = true;
          name = "crowdsec";
        }

        {
          ensureDBOwnership = true;
          name = "dockhand";
        }
        # keep-sorted end
      ];

      authentication = ''
        local all all peer
        host all all 127.0.0.1/32 scram-sha-256
        host all all ::1/128 scram-sha-256
      '';
    };

    services.postgresqlBackup = {
      enable = true;
      startAt = "*-*-* 02:00:00";

      compression = "zstd";
      compressionLevel = 3;
    };
  };
}
