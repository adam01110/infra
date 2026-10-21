{inputs, ...}: {
  flake-file.inputs.albedo-suite = {
    url = "git+https://tangled.org/did:plc:4yew6fq5qsishjxq7mizijnz";
    # Keep the suite's NUR revision matched to its source pin.
    inputs = {
      # keep-sorted start
      flake-parts.follows = "flake-parts";
      home-manager.follows = "home-manager";
      import-tree.follows = "import-tree";
      nixpkgs.follows = "nixpkgs";
      treefmt-nix.follows = "treefmt-nix";
      # keep-sorted end
    };
  };

  flake.modules.homeManager.albedo = {
    # keep-sorted start
    config,
    pkgs,
    # keep-sorted end
    ...
  }: let
    # Use the host package set so the suite inherits its unfree policy.
    suite = (import "${inputs.albedo-suite}/flake.nix").outputs suiteInputs;
    suiteInputs =
      inputs.albedo-suite.inputs
      // {
        self = inputs.albedo-suite // suite // {inputs = suiteInputs;};
        nixpkgs =
          inputs.nixpkgs
          // {
            legacyPackages =
              inputs.nixpkgs.legacyPackages
              // {
                ${pkgs.stdenv.hostPlatform.system} = pkgs;
              };
          };
      };
  in {
    imports = [suite.homeManagerModules.default];
    programs.albedo = {
      enable = true;
      appendInstructions = ./APPEND_SYSTEM.md;
      environment = {
        GNUPGHOME = config.programs.gpg.homedir;
        JJ_CONFIG = config.sops.templates."jj-user-config".path;
      };
    };
  };
}
