{inputs, ...}: {
  flake-file.inputs.nur = {
    url = "github:nix-community/NUR";

    inputs = {
      # keep-sorted start
      flake-parts.follows = "flake-parts";
      nixpkgs.follows = "nixpkgs";
      # keep-sorted end
    };
  };

  flake.modules.nixos.nur.imports = [inputs.nur.modules.nixos.default];
}
