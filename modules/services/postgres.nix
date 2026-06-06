{
  flake.modules.nixos.postgres = {pkgs, ...}: {
    services.postgresql = {
      enable = true;
      enableTCPIP = true;

      package = pkgs.postgresql_18;
    };

    services.postgresqlBackup = {
      enable = true;
      compression = "zstd";
      compressionLevel = 3;
      startAt = "*-*-* 02:00:00";
    };
  };
}
