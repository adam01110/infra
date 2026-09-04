{
  # keep-sorted start
  inputs,
  self,
  # keep-sorted end
  ...
}: {
  imports = [inputs.home-manager.flakeModules.home-manager];

  flake-file.inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake = {
    homeModules = self.modules.homeManager;

    modules.nixos.home-manager = {
      # keep-sorted start
      config,
      pkgs,
      vars,
      # keep-sorted end
      ...
    }: let
      inherit (vars) username;
    in {
      imports = [
        # keep-sorted start
        inputs.home-manager.nixosModules.home-manager
        self.modules.generic.vars
        # keep-sorted end
      ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = {
          inherit
            # keep-sorted start
            inputs
            pkgs
            self
            vars
            # keep-sorted end
            ;
        };

        startAsUserService = true;
        backupCommand = "${pkgs.trash-cli}/bin/trash";

        users.${username} = {
          home = {
            inherit username;
            enableNixpkgsReleaseCheck = false;
            homeDirectory = "/home/${username}";

            # Align home manager state version with the system.
            inherit (config.system) stateVersion;
          };
        };
      };
    };
  };
}
