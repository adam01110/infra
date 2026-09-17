{self, ...}: {
  flake.modules = {
    nixos.noctalia = {
      nixpkgs.overlays = [self.overlays.pkgs];

      # The screen recorder plugin captures the monitor directly, which needs the
      # sys_admin capped gsr-kms-server wrapper instead of a portal session.
      programs.gpu-screen-recorder.enable = true;
    };

    homeManager.noctalia = {lib, ...}: let
      inherit (lib) mkEnableOption;
    in {
      options.programs.noctalia.battery.enable = mkEnableOption "battery widgets";

      config.programs.noctalia = {
        enable = true;
        systemd.enable = true;

        settings.audio.enable_overdrive = true;
      };
    };
  };
}
