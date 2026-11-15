{
  # keep-sorted start
  config,
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
    # keep-sorted end
    ;

  inherit (self.vars) username;

  hosts = {
    # keep-sorted start
    desktop = "x86_64-linux";
    laptop = "x86_64-linux";
    # keep-sorted end

    # keep-sorted start
    euclid = "x86_64-linux";
    # keep-sorted end
  };
in {
  flake.nixosConfigurations = mapAttrs (name: system: let
    aspect = config.flake.aspects.${name};
  in
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
        (aspect.resolve {class = "nixos";})
        {
          nixpkgs.hostPlatform = mkDefault system;

          # Each host's Home Manager half resolves from the same aspect tree.
          home-manager.users.${username}.imports = [(aspect.resolve {class = "homeManager";})];
        }
      ];
    })
  hosts;
}
