{lib, ...}: let
  inherit (lib) mkEnableOption;
in {
  flake.modules.nixos.capabilities = {
    options.capabilities = {
      # keep-sorted start
      bluetooth = mkEnableOption "bluetooth support";
      gpuVram = mkEnableOption "GPU VRAM monitoring support";
      wifi = mkEnableOption "wifi support";
      # keep-sorted end
    };
  };
}
