{
  flake.modules.nixos.bpftune = {
    # Auto-tune kernel bpf settings for performance.
    services.bpftune.enable = true;
  };
}
