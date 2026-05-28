{lib, ...}: let
  inherit (lib) mkEnableOption;
in {
  flake.modules.nixos.capabilities = {
    key = "nixos-capabilities";

    options.capabilities = {
      # keep-sorted start
      bluetooth = mkEnableOption "bluetooth support";
      wifi = mkEnableOption "wifi support";
      # keep-sorted end
    };
  };
}
