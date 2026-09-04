{self, ...}: {
  flake.modules = {
    nixos.noctalia.nixpkgs.overlays = [self.overlays.pkgs];

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
