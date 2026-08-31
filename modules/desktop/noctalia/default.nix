{self, ...}: {
  flake.modules.nixos.noctalia.nixpkgs.overlays = [self.overlays.pkgs];

  flake.modules.homeManager.noctalia = {lib, ...}: let
    inherit (lib) mkEnableOption;
  in {
    options.programs.noctalia.battery.enable = mkEnableOption "battery widgets";

    config.programs.noctalia = {
      enable = true;
      systemd.enable = true;

      settings.audio.enable_overdrive = true;
    };
  };
}
