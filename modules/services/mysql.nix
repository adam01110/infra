{
  flake.modules.nixos.mysql = {pkgs, ...}: {
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
  };
}
