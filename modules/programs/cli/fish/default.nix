{
  flake.modules.nixos.fish.programs.fish.enable = true;

  flake.modules.homeManager.fish = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      concatStringsSep
      mkOption
      types
      # keep-sorted end
      ;

    cfg = config.programs.fish;
  in {
    options.programs.fish.interactiveShellInitSnippets = mkOption {
      description = "Fish snippets concatenated into interactiveShellInit.";

      type = types.listOf types.lines;
      default = [];
    };

    config = {
      programs.fish = {
        enable = true;

        interactiveShellInit = concatStringsSep "\n" cfg.interactiveShellInitSnippets;

        binds = {
          # keep-sorted start
          "alt-d".erase = true;
          "alt-e".erase = true;
          "alt-l".erase = true;
          # keep-sorted end
        };
      };

      home.packages = [pkgs.file];
    };
  };
}
