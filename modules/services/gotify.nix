{
  flake.modules.nixos.gotify = {lib, ...}: let
    inherit (lib) mkForce;
  in {
    services.gotify = {
      enable = true;
      stateDirectoryName = "gotify";

      environment = {
        GOTIFY_SERVER_PORT = 44407;
        GOTIFY_DATABASE_CONNECTION = "host=/run/postgresql user=gotify dbname=gotify sslmode=disable";
        GOTIFY_DATABASE_DIALECT = "postgres";
      };
    };

    users = {
      groups.gotify = {};
      users.gotify = {
        group = "gotify";
        isSystemUser = true;
      };
    };

    systemd.services.gotify-server = {
      after = ["postgresql.service"];
      requires = ["postgresql.service"];

      serviceConfig = {
        DynamicUser = mkForce false;
        User = "gotify";
        Group = "gotify";
      };
    };
  };
}
