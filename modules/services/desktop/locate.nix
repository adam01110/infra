{
  flake.aspects.locate.nixos = {
    services.locate = {
      enable = true;

      interval = "daily";
    };
  };
}
