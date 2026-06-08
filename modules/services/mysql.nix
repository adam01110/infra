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
    sops.secrets."mysql/admin_password" = {};

    services.mysql = {
      enable = true;
      package = pkgs.mariadb;

      settings = {
        mysqld = {
          # TODO: Revisit database exposure once the access model is decided.
          bind-address = "127.0.0.1";
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

    systemd.services.mysql-admin = {
      # keep-sorted start block=yes newline_separated=yes
      after = [
        "mysql.service"
        "sops-install-secrets.service"
      ];

      requiredBy = ["multi-user.target"];

      requires = [
        "mysql.service"
        "sops-install-secrets.service"
      ];
      # keep-sorted end

      script = ''
        set -eu
        password="$(${pkgs.coreutils}/bin/cat "$CREDENTIALS_DIRECTORY/admin_password")"
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
        LoadCredential = ["admin_password:${config.sops.secrets."mysql/admin_password".path}"];
        RemainAfterExit = true;
        # keep-sorted end
      };
    };
  };
}
