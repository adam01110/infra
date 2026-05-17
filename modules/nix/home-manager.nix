{inputs, ...}: {
  flake-file.inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  imports = [inputs.home-manager.flakeModules.home-manager];

  flake.modules.nixos.home-manager = {
    config,
    vars,
    ...
  }: let
    inherit (vars) username;
  in {
    imports = [inputs.home-manager.nixosModules.home-manager];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      backupFileExtension = "backup";

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
