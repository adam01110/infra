{
  inputs,
  self,
  ...
}: let
  sopsConfig = {
    # Keep the shared secret inventory in the repository copy.
    defaultSopsFile = "${self}/secrets/secrets.yaml";
    defaultSopsFormat = "yaml";

    validateSopsFiles = false;

    # Use a pre-provisioned age key file on disk.
    age = {
      sshKeyPaths = [];
      generateKey = false;
      keyFile = "/var/lib/sops-nix/key.txt";
    };
  };
in {
  flake-file.inputs = {
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.nixos.sops = {
    imports = [inputs.sops-nix.nixosModules.sops];
    sops = sopsConfig;
  };

  flake.modules.homeManager.sops = {
    imports = [inputs.sops-nix.homeManagerModules.sops];
    sops = sopsConfig;
  };
}
