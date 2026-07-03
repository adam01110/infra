{inputs, ...}: {
  flake-file.inputs.treefmt-nix = {
    url = "github:numtide/treefmt-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  imports = [inputs.treefmt-nix.flakeModule];

  perSystem = _: {
    treefmt = {
      # keep-sorted start block=yes newline_separated=yes
      programs = {
        # keep-sorted start
        alejandra.enable = true;
        deadnix.enable = true;
        nixf-diagnose.enable = true;
        statix.enable = true;
        # keep-sorted end

        # keep-sorted start block=yes
        shellcheck = {
          enable = true;
          severity = "style";
        };
        shfmt.enable = true;
        # keep-sorted end

        # keep-sorted start
        keep-sorted.enable = true;
        oxfmt.enable = true;
        rumdl-format.enable = true;
        stylua.enable = true;
        yamllint.enable = true;
        # keep-sorted end
      };

      projectRootFile = "flake.nix";

      settings = {
        # keep-sorted start block=yes newline_separated=yes
        # Keep markdown on rumdl-format.
        formatter.oxfmt.excludes = [
          "*.md"
          "*.mdx"
        ];

        global.excludes = [
          # keep-sorted start
          ".direnv/*"
          ".envrc"
          ".sops.yaml"
          "flake.nix"
          "secrets.yaml"
          # keep-sorted end
        ];
        # keep-sorted end
      };
      # keep-sorted end
    };
  };
}
