{inputs, ...}: {
  flake-file.inputs.nur = {
    url = "github:nix-community/NUR";
    inputs = {
      flake-parts.follows = "flake-parts";
      nixpkgs.follows = "nixpkgs";
    };
  };
  flake.modules.nixos.nur = {
    imports = [inputs.nur.modules.nixos.default];
  };

  flake.modules.homeManager.nur = {
    imports = [inputs.nur.modules.homeManager.default];
  };
}
