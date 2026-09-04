{
  flake.modules.nixos.mysql = {
    # keep-sorted start
    config,
    pkgs,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (vars) username;
  in {
    sops.secrets.mysql_admin_password = {};

    services.mysql = {
      enable = true;
      package = pkgs.mariadb;

      settings = {
        mysqld = {
          # Bind only to loopback and WireGuard; containers route via wg0.
          bind-address = "127.0.0.1,10.100.0.1";
          innodb_buffer_pool_size = "512M";
          max_connections = 100;
          slow_query_log = true;
          long_query_time = 1;
        };

        mysqldump.max_allowed_packet = "64M";
      };
    };

    services.mysqlBackup = {
      enable = true;
      calendar = "02:00:00";

      compressionAlg = "zstd";
      compressionLevel = 3;
    };

    networking.firewall = {
      interfaces.wg0.allowedTCPPorts = [3306];

      extraInputRules = ''
        # Allow containers to reach host MariaDB.
        iifname "podman*" tcp dport 3306 accept
      '';
    };

    systemd.services.mysql-admin = {
      # keep-sorted start block=yes newline_separated=yes
      after = [
        # keep-sorted start
        "mysql.service"
        "sops-install-secrets.service"
        # keep-sorted end
      ];

      wantedBy = ["multi-user.target"];

      wants = [
        # keep-sorted start
        "mysql.service"
        "sops-install-secrets.service"
        # keep-sorted end
      ];
      # keep-sorted end

      script = ''
        set -eu
        password="$(${pkgs.coreutils}/bin/tr -d '\r\n' < "$CREDENTIALS_DIRECTORY/admin_password")"
        escaped_password="''${password//\'/\'\'}"
        ${config.services.mysql.package}/bin/mysql -e "
          CREATE USER IF NOT EXISTS '${username}'@'127.0.0.1' IDENTIFIED BY '$escaped_password';
          ALTER USER '${username}'@'127.0.0.1' IDENTIFIED BY '$escaped_password';
          GRANT ALL PRIVILEGES ON *.* TO '${username}'@'127.0.0.1' WITH GRANT OPTION;
          FLUSH PRIVILEGES;
        "
      '';

      serviceConfig = {
        # keep-sorted start
        Group = "root";
        Type = "oneshot";
        User = "root";
        # keep-sorted end

        # keep-sorted start
        LoadCredential = ["admin_password:${config.sops.secrets.mysql_admin_password.path}"];
        RemainAfterExit = true;
        # keep-sorted end
      };
    };
  };
}
