{
  flake.modules.nixos.envfs = {
    # Provide fhs-style paths for compatibility with legacy applications.
    services.envfs.enable = true;
  };
}
