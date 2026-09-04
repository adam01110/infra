{
  flake.modules.nixos.postgres = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (lib) mkForce;

    inherit (vars) username;
  in {
    sops.secrets.postgres_admin_password = {};

    services.postgresql = {
      enable = true;
      enableTCPIP = true;

      package = pkgs.postgresql_18;

      settings = {
        # Listen only on local and WireGuard addresses.
        listen_addresses = mkForce "127.0.0.1,::1,10.100.0.1";

        # keep-sorted start
        log_connections = true;
        log_disconnections = true;
        log_min_duration_statement = 1000;
        maintenance_work_mem = "128MB";
        shared_buffers = "256MB";
        # keep-sorted end
      };

      ensureDatabases = [
        # keep-sorted start
        "cloudbeaver"
        "crowdsec"
        "dockhand"
        "gotify"
        # keep-sorted end
      ];

      ensureUsers = [
        # keep-sorted start block=yes newline_separated=yes
        {
          ensureDBOwnership = true;
          name = "cloudbeaver";
        }

        {
          ensureDBOwnership = true;
          name = "crowdsec";
        }

        {
          ensureDBOwnership = true;
          name = "dockhand";
        }

        {
          ensureDBOwnership = true;
          name = "gotify";
        }

        {
          name = username;
        }
        # keep-sorted end
      ];

      authentication = ''
        local all +container_login scram-sha-256
        local all all peer
        host all all 127.0.0.1/32 scram-sha-256
        host all all ::1/128 scram-sha-256
        host all all 10.100.0.0/24 scram-sha-256
      '';
    };

    services.postgresqlBackup = {
      enable = true;
      startAt = "*-*-* 02:00:00";

      compression = "zstd";
      compressionLevel = 3;
    };

    networking.firewall.interfaces.wg0.allowedTCPPorts = [5432];

    systemd.services.postgres-admin = {
      # keep-sorted start block=yes newline_separated=yes
      after = [
        # keep-sorted start
        "postgresql.service"
        "sops-install-secrets.service"
        # keep-sorted end
      ];

      wantedBy = ["multi-user.target"];

      wants = [
        # keep-sorted start
        "postgresql.service"
        "sops-install-secrets.service"
        # keep-sorted end
      ];
      # keep-sorted end

      script = ''
        set -eu
        password="$(${pkgs.coreutils}/bin/tr -d '\r\n' < "$CREDENTIALS_DIRECTORY/admin_password")"
        ${config.services.postgresql.package}/bin/psql --dbname postgres --command "ALTER USER ${username} WITH SUPERUSER PASSWORD \''$${username}\''$''${password}\''$${username}\''$;"
      '';

      serviceConfig = {
        # keep-sorted start
        Group = "postgres";
        Type = "oneshot";
        User = "postgres";
        # keep-sorted end

        # keep-sorted start
        LoadCredential = ["admin_password:${config.sops.secrets.postgres_admin_password.path}"];
        RemainAfterExit = true;
        # keep-sorted end
      };
    };
  };
}
