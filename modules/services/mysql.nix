{
  flake.modules.nixos.mysql = {pkgs, ...}: {
    services.mysql = {
      enable = true;
      package = pkgs.mariadb;
    };

    services.mysqlBackup = {
      enable = true;
      calendar = "02:00:00";
      compressionAlg = "zstd";
      compressionLevel = 3;
    };
  };
}
