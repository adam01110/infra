{
  # keep-sorted start
  inputs,
  self,
  # keep-sorted end
  ...
}: let
  defaultConfig = {
    defaultSopsFile = "${self}/secrets.yaml";
    defaultSopsFormat = "yaml";
    validateSopsFiles = false;
  };

  defaultAgeConfig = {
    sshKeyPaths = [];
    generateKey = false;
  };
in {
  flake-file.inputs = {
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.nixos.sops = {vars, ...}: let
    inherit (vars) username;
  in {
    imports = [inputs.sops-nix.nixosModules.sops];

    systemd.tmpfiles.rules = [
      "d /home/${username}/.config/sops 0700 ${username} users - -"
      "d /home/${username}/.config/sops/age 0700 ${username} users - -"
      "C /home/${username}/.config/sops/age/key.txt 0400 ${username} users - /var/lib/sops-nix/key.txt"
    ];

    sops =
      defaultConfig
      // {
        # Use a pre-provisioned age key file on disk.
        age = defaultAgeConfig // {keyFile = "/var/lib/sops-nix/key.txt";};
      };
  };

  flake.modules.homeManager.sops = {vars, ...}: let
    inherit (vars) username;
  in {
    imports = [inputs.sops-nix.homeManagerModules.sops];

    sops =
      defaultConfig
      // {
        # User service cannot read the root-owned system key.
        age = defaultAgeConfig // {keyFile = "/home/${username}/.config/sops/age/key.txt";};
      };
  };
}
