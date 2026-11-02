{inputs, ...}: {
  flake-file.inputs.nixcord = {
    url = "github:kaylorben/nixcord";
    inputs = {
      # keep-sorted start
      home-manager.follows = "home-manager";
      nixpkgs.follows = "nixpkgs";
      treefmt-nix.follows = "treefmt-nix";
      # keep-sorted end
    };
  };

  flake.modules.homeManager.discord = {
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
      concatMapStringsSep
      escapeShellArg
      genAttrs
      getExe'
      mkForce
      # keep-sorted end
      ;
    inherit (lib.hm) dag;

    inherit (pkgs) coreutils;
    inherit (pkgs.nur.repos.adam0) equibop-fixed;

    settingsPaths = [
      # keep-sorted start
      "${config.programs.nixcord.equibop.configDir}/settings.json"
      "${config.programs.nixcord.equibop.configDir}/settings/settings.json"
      # keep-sorted end
    ];
  in {
    imports = [inputs.nixcord.homeModules.nixcord];

    programs.nixcord = {
      enable = true;
      discord.enable = false;

      equibop = {
        enable = true;
        package = equibop-fixed;
        configDir = "${config.xdg.configHome}/equibop";
      };
    };

    # Let Equibop persist runtime changes to its generated settings.
    home = {
      file = genAttrs settingsPaths (_: {enable = mkForce false;});

      activation.nixcordEquibopWritableSettings = dag.entryAfter ["writeBoundary"] (
        concatMapStringsSep "\n" (path: ''
          settings=${escapeShellArg path}
          if [[ -L "$settings" ]]; then
            run rm "$settings"
          fi
          run ${getExe' coreutils "install"} -Dm644 ${escapeShellArg config.home.file.${path}.source} "$settings"
        '')
        settingsPaths
      );
    };
  };
}
