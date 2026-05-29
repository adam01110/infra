{inputs, ...}: {
  flake-file.inputs.disko = {
    url = "github:nix-community/disko?ref=latest";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  imports = [inputs.disko.flakeModules.disko];

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

    options.disko.selectedDisk = mkOption {
      description = "Disk device to use for the selected disko layout.";

      type = types.str;
      example = "/dev/nvme0n1";
    };
  };
}
