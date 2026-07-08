{lib, ...}: {
  flake.modules.nixos.nix = {
    # keep-sorted start
    config,
    vars,
    # keep-sorted end
    ...
  }: let
    inherit (vars) username;
  in {
    sops = {
      secrets."nix_access_tokens/github" = {};

      templates = {
        access_tokens = {
          content = ''
            access-tokens = github.com=${config.sops.placeholder."nix_access_tokens/github"}
          '';
          owner = username;
        };

        nix-netrc = {
          content = let
            ncpsHost = "ncps.${vars.groundDomain}";
          in ''
            machine ${ncpsHost}
              login nix
              password ${config.sops.placeholder."nix_access_tokens/ncps"}
          '';
          group = "root";
          mode = "0400";
          owner = "root";
        };
      };
    };

    nix = {
      settings = let
        substituters = [
          # keep-sorted start
          "https://adam01110-nur.cachix.org/"
          "https://cache.numtide.com"
          "https://forkprince.cachix.org/"
          "https://mic92.cachix.org"
          "https://nix-community.cachix.org"
          # keep-sorted end
        ];
      in {
        inherit substituters;

        trusted-substituters = substituters;

        trusted-public-keys = [
          # keep-sorted start
          "adam01110-nur.cachix.org-1:43B8awTREG19aQ20luDD9BkxijKG/Q7hf8voMzS1X9I="
          "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
          "forkprince.cachix.org-1:9cN+fX492ZKlfd228xpYAC3T9gNKwS1sZvCqH8iAy1M="
          "mic92.cachix.org-1:gi8IhgiT3CYZnJsaW7fxznzTkMUOn1RY4GmXdT/nXYQ="
          "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          # keep-sorted end
        ];

        netrc-file = config.sops.templates.nix-netrc.path;

        experimental-features = [
          # keep-sorted start
          "flakes"
          "nix-command"
          "pipe-operators"
          # keep-sorted end
        ];

        lazy-trees = true;
        eval-cores = 0;

        # Store profile and channel links under XDG state directories.
        use-xdg-base-directories = true;
      };

      # Load access tokens from the generated sops template.
      extraOptions = "!include ${config.sops.templates.access_tokens.path}";
    };

    nixpkgs.config = {
      allowInsecurePredicate = pkg:
        (lib.getName pkg == "electron" && lib.getVersion pkg == "39.8.10")
        || (lib.getName pkg == "nodejs" && lib.hasPrefix "20." (lib.getVersion pkg));
      allowUnfree = true;
    };
  };
}
