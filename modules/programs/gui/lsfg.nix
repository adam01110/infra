{
  flake.modules.nixos.lsfg = {pkgs, ...}: let
    inherit (builtins) attrValues;
  in {
    # Add lossless scaling linux packages.
    environment.systemPackages = attrValues {
      inherit
        (pkgs)
        # keep-sorted start
        lsfg-vk
        lsfg-vk-ui
        # keep-sorted end
        ;
    };
  };
}
