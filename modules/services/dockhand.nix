{
  flake.modules.nixos.dockhand = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) mkForce;

    secrets = config.sops.secrets;
    templates = config.sops.templates;
  in {
    sops = {
      secrets."dockhand/database_password" = {};

      templates."dockhand.env".content = ''
        DATABASE_URL=postgres://dockhand:${config.sops.placeholder."dockhand/database_password"}@127.0.0.1:5432/dockhand
      '';
    };

    virtualisation.oci-containers.containers.dockhand = {
      hostname = "dockhand";
      image = "fnsys/dockhand:latest";

      extraOptions = [
        "--network=host"

        # Health check.
        "--health-cmd=curl -fsSo /dev/null http://127.0.0.1:3000/api/health || exit 1"
        "--health-interval=60s"
        "--health-retries=5"
        "--health-start-period=30s"
        "--health-timeout=5s"
      ];

      environmentFiles = [templates."dockhand.env".path];
      volumes = ["/var/lib/dockhand:/app/data"];
    };

    systemd = {
      tmpfiles.rules = ["d /var/lib/dockhand 0750 1001 1001 -"];

      services = {
        dockhand-postgres-password = {
          # keep-sorted start block=yes newline_separated=yes
          after = [
            "postgresql.service"
            "sops-install-secrets.service"
          ];

          before = ["podman-dockhand.service"];

          wantedBy = ["podman-dockhand.service"];

          wants = [
            "postgresql.service"
            "sops-install-secrets.service"
          ];
          # keep-sorted end

          script = ''
            set -eu
            password="$(${pkgs.coreutils}/bin/cat "$CREDENTIALS_DIRECTORY/database_password")"
            ${config.services.postgresql.package}/bin/psql --dbname postgres --command "ALTER USER dockhand WITH PASSWORD \$dockhand\$''${password}\$dockhand\$;"
          '';

          serviceConfig = {
            # keep-sorted start
            Group = "postgres";
            Type = "oneshot";
            User = "postgres";
            # keep-sorted end

            # keep-sorted start
            LoadCredential = ["database_password:${secrets."dockhand/database_password".path}"];
            RemainAfterExit = true;
            # keep-sorted end
          };
        };

        podman-dockhand = {
          after = ["dockhand-postgres-password.service"];
          stopIfChanged = false;
          wants = ["dockhand-postgres-password.service"];

          serviceConfig = {
            SuccessExitStatus = [143];
            TimeoutStopSec = mkForce "60s";
          };
        };
      };
    };
  };
}
