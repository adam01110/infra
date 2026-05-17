{
  flake-file.inputs.lanzaboote = {
    url = "github:nix-community/lanzaboote?ref=v1.0.0";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.lanzaboote = {
    # keep-sorted start
    
    inputs,
    lib,
    pkgs, ...
    # keep-sorted end
  }: let
    inherit (builtins) attrValues;
    inherit (lib) mkForce;
  in {
    imports = [inputs.lanzaboote.nixosModules.lanzaboote];

    nix.settings = let
      cache = "https://lanzaboote.cachix.org";
    in {
      substituters = [cache];
      trusted-substituters = [cache];
      trusted-public-keys = ["lanzaboote.cachix.org-1:Nt9//zGmqkg1k5iu+B3bkj3OmHKjSw9pvf3faffLLNk="];
    };

    boot = {
      initrd.systemd.enable = true;

      loader = {
        # Skip bootloader timeout for faster boot.
        timeout = 0;

        # Secure boot is handled via lanzaboote below.
        systemd-boot.enable = mkForce false;
        efi.canTouchEfiVariables = true;
      };

      lanzaboote = {
        enable = true;

        # Manage secure boot keys on the host during initial setup.
        autoGenerateKeys.enable = true;
        autoEnrollKeys = {
          # Reboot after enrollment so firmware picks up the new keys.
          enable = true;
          autoReboot = true;
        };

        pkiBundle = "/var/lib/sbctl";
      };
    };

    # Extra packages for lanzaboote.
    environment.systemPackages = attrValues {
      inherit
        (pkgs)
        # keep-sorted start
        sbctl
        tpm2-tss
        # keep-sorted end
        ;
    };
  };
}
