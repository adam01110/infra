{
  flake.aspects.bpftune.nixos = {
    services.bpftune.enable = true;
  };
}
