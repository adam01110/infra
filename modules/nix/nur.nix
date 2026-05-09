{
  inputs,
  self,
  ...
}: {
  flake-file.inputs.nur = {
    url = "github:nix-community/NUR";
    inputs = {
      flake-parts.follows = "flake-parts";
      nixpkgs.follows = "nixpkgs";
    };
  };

  flake.overlays.nur = inputs.nur.overlays.default;

  flake.modules.nixos.nur = {
    imports = [inputs.nur.modules.nixos.default];
  };

  flake.modules.homeManager.nur = {
    nixpkgs.overlays = [self.overlays.nur];
  };
}
