{
  flake.modules.nixos.locate = {
    services.locate = {
      enable = true;

      interval = "daily";
    };
  };
}
