{inputs, ...}: {
  flake-file.inputs = {
    url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  imports = [inputs.home-manager.flakeModules.home-manager];
}
