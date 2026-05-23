{inputs, ...}: {
  flake.modules.nixos.disko = {lib, ...}: let
    inherit
      (lib)
      # keep-sorted start
      mkOption
      types
      # keep-sorted end
      ;
  in {
    imports = [inputs.disko.nixosModules.disko];

    options.disko.disk = mkOption {
      type = types.str;
      example = "/dev/nvme0n1";
      description = "Disk device to use for the selected disko layout.";
    };
  };
}
