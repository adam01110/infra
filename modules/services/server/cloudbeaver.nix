{
  flake.modules.nixos.cloudbeaver = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (lib) mkForce;

    secrets = config.sops.secrets;
    templates = config.sops.templates;

    inherit (vars) groundDomain;
  in {
    sops = {
      secrets.cloudbeaver_database_password = {};

      templates."cloudbeaver.env".content = ''
        CLOUDBEAVER_DB_PASSWORD=${config.sops.placeholder.cloudbeaver_database_password}
        CLOUDBEAVER_QM_DB_PASSWORD=${config.sops.placeholder.cloudbeaver_database_password}
      '';
    };

    virtualisation.oci-containers.containers.cloudbeaver = {
      hostname = "cloudbeaver";
      image = "docker.io/dbeaver/cloudbeaver:latest";
      labels."io.containers.autoupdate" = "registry";

      extraOptions = [
        "--network=host"

        # Health check.
        "--health-cmd=curl -fsSo /dev/null http://127.0.0.1:8978/ || exit 1"
        "--health-interval=60s"
        "--health-retries=5"
        "--health-start-period=30s"
        "--health-timeout=5s"
      ];

      environment = {
        CB_SERVER_URL = "https://cloudbeaver.${groundDomain}";
        CLOUDBEAVER_APP_FORWARD_PROXY = "true";
        CLOUDBEAVER_DB_BACKUP_ENABLED = "false";
        CLOUDBEAVER_DB_DRIVER = "postgres-jdbc";
        CLOUDBEAVER_DB_SCHEMA = "public";
        CLOUDBEAVER_DB_URL = "jdbc:postgresql://127.0.0.1:5432/cloudbeaver";
        CLOUDBEAVER_DB_USER = "cloudbeaver";
        CLOUDBEAVER_QM_DB_BACKUP_ENABLED = "false";
        CLOUDBEAVER_QM_DB_DRIVER = "postgres-jdbc";
        CLOUDBEAVER_QM_DB_SCHEMA = "public";
        CLOUDBEAVER_QM_DB_URL = "jdbc:postgresql://127.0.0.1:5432/cloudbeaver";
        CLOUDBEAVER_QM_DB_USER = "cloudbeaver";
      };

      environmentFiles = [templates."cloudbeaver.env".path];
      volumes = ["/var/lib/cloudbeaver:/opt/cloudbeaver/workspace"];
    };

    systemd = {
      tmpfiles.rules = ["d /var/lib/cloudbeaver 0750 8978 8978 -"];

      services = {
        cloudbeaver-postgres-password = {
          # keep-sorted start block=yes newline_separated=yes
          after = [
            "postgresql.service"
            "sops-install-secrets.service"
          ];

          before = ["podman-cloudbeaver.service"];

          wantedBy = ["podman-cloudbeaver.service"];

          wants = [
            "postgresql.service"
            "sops-install-secrets.service"
          ];
          # keep-sorted end

          script = ''
            set -eu
            password="$(${pkgs.coreutils}/bin/cat "$CREDENTIALS_DIRECTORY/database_password")"
            ${config.services.postgresql.package}/bin/psql --dbname postgres --command "ALTER USER cloudbeaver WITH PASSWORD \$cloudbeaver\$''${password}\$cloudbeaver\$;"
          '';

          serviceConfig = {
            # keep-sorted start
            Group = "postgres";
            Type = "oneshot";
            User = "postgres";
            # keep-sorted end

            # keep-sorted start
            LoadCredential = ["database_password:${secrets.cloudbeaver_database_password.path}"];
            RemainAfterExit = true;
            # keep-sorted end
          };
        };

        podman-cloudbeaver = {
          after = ["cloudbeaver-postgres-password.service"];
          stopIfChanged = false;
          wants = ["cloudbeaver-postgres-password.service"];

          serviceConfig = {
            SuccessExitStatus = [143];
            TimeoutStopSec = mkForce "60s";
          };
        };
      };
    };
  };
}
