{
  inputs,
  self,
  ...
}: {
  imports = [inputs.home-manager.flakeModules.home-manager];

  flake.homeModules = self.modules.homeManager;

  flake-file.inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.nixos.home-manager = {
    # keep-sorted start
    config,
    pkgs,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (vars) username;
  in {
    imports = [inputs.home-manager.nixosModules.home-manager];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      startAsUserService = true;
      backupCommand = "${pkgs.trash-cli}/bin/trash";

      users.${username} = {
        home = {
          inherit username;
          homeDirectory = "/home/${username}";

          # Align home manager state version with the system.
          inherit (config.system) stateVersion;
        };
      };
    };
  };
}
