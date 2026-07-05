{self, ...}: {
  flake.overlays.envfs = _final: prev: let
    src = prev.fetchFromGitHub {
      owner = "Mic92";
      repo = "envfs";
      rev = "1.2.0";
      hash = "sha256-hj/6zS9ebF0IDqgc1Dne59nWx80nk6jn2gj8BzQUFIQ=";
    };
  in {
    # Pin envfs until nixpkgs picks up the upstream mount helper fix.
    envfs = prev.envfs.overrideAttrs (_oldAttrs: {
      version = "1.2.0";
      inherit src;
      cargoDeps = prev.rustPlatform.fetchCargoVendor {
        inherit src;
        hash = "sha256-dz3gpE464jnmSDsAsmJHcxUsEKeUURNoUjgGU2214Xg=";
      };
    });
  };

  flake.modules.nixos.envfs = {
    nixpkgs.overlays = [self.overlays.envfs];

    # Provide fhs-style paths for compatibility with legacy applications.
    services.envfs.enable = true;
  };
}
