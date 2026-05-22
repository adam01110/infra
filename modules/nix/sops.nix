{inputs, ...}: let
  sopsConfig = {
    # Keep the shared secret inventory outside the public infra repo.
    defaultSopsFile = "${inputs.secrets}/secrets.yaml";
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
    secrets = {
      url = "git+ssh://git@github.com/adam01110/secrets.git";
      flake = false;
    };

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
