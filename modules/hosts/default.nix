{
  #keep-sorted start
  inputs,
  lib,
  self,
  # keep-sorted end
  ...
}: let
  inherit
    (lib)
    # keep-sorted start
    mapAttrs
    mkDefault
    optionalAttrs
    # keep-sorted end
    ;

  hosts = {
    # keep-sorted start
    desktop = "x86_64-linux";
    laptop = "x86_64-linux";
    vm = "x86_64-linux";
    # keep-sorted end
  };
in {
  perSystem = {system, ...}:
    optionalAttrs (system == hosts.vm) {
      packages.vm = self.nixosConfigurations.vm.config.system.build.vm;
    };

  flake.nixosConfigurations = mapAttrs (name: system:
    self.lib.nixosSystem {
      specialArgs = {
        inherit
          # keep-sorted start
          inputs
          self
          # keep-sorted end
          ;
        inherit (self) vars;
      };

      modules = [
        self.modules.nixos.${name}
        {nixpkgs.hostPlatform = mkDefault system;}
      ];
    })
  hosts;
}
