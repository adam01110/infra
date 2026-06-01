{
  flake.modules.nixos.postgres = {pkgs, ...}: {
    services.postgresql = {
      enable = true;
      enableTCPIP = true;

      package = pkgs.postgresql_18;
    };
  };
}
