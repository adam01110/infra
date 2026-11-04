{inputs, ...}: let
  inherit
    (builtins)
    # keep-sorted start
    fromJSON
    readFile
    # keep-sorted end
    ;

  forkprinceRevision = (fromJSON (readFile "${inputs.nur}/repos.json.lock")).repos.forkprince;

  # Avoid ZIP filename decoding failures while preserving the NUR revision and hash.
  forkprinceSource = fetchTarball {
    url = "${forkprinceRevision.url}/archive/${forkprinceRevision.rev}.tar.gz";
    inherit (forkprinceRevision) sha256;
  };
in {
  flake-file.inputs.nur = {
    url = "github:nix-community/NUR";

    inputs = {
      # keep-sorted start
      flake-parts.follows = "flake-parts";
      nixpkgs.follows = "nixpkgs";
      # keep-sorted end
    };
  };

  flake.modules.nixos.nur.nixpkgs.overlays = [
    (_final: pkgs: {
      nur = import inputs.nur {
        inherit pkgs;
        nurpkgs = pkgs;
        repoOverrides.forkprince = import forkprinceSource {inherit pkgs;};
      };
    })
  ];
}
