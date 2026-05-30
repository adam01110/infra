{
  inputs,
  lib,
  self,
  ...
}: let
  hosts = {
    # keep-sorted start
    desktop = "x86_64-linux";
    laptop = "x86_64-linux";
    vm = "x86_64-linux";
    # keep-sorted end
  };
in {
  perSystem = {system, ...}:
    lib.optionalAttrs (system == hosts.vm) {
      packages.vm = self.nixosConfigurations.vm.config.system.build.vm;
    };

  flake.nixosConfigurations = lib.mapAttrs (name: system:
    self.lib.nixosSystem {
      specialArgs = {
        inherit inputs self;
        inherit (self) vars;
      };

      modules = [
        self.modules.nixos.${name}
        {nixpkgs.hostPlatform = lib.mkDefault system;}
      ];
    })
  hosts;
}
