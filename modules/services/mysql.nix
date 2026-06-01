{
  flake.modules.nixos.mysql = {
    services.mysql = {
      enable = true;
    };
  };
}
