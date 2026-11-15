{
  flake.aspects.keyd.nixos.services.keyd = {
    enable = true;

    keyboards.default = {
      ids = ["*"];
      settings.main = {
        capslock = "esc";
        esc = "capslock";
      };
    };
  };

  # keyd exits with status 15 on SIGTERM, which marks a clean stop as failed.
  flake.aspects.keyd.nixos.systemd.services.keyd.serviceConfig.SuccessExitStatus = [15];
}
