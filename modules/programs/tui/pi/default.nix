{inputs, ...}: {
  flake-file.inputs.pi-nix = {
    url = "github:lukasl-dev/pi.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.pi = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (builtins) attrValues;
    inherit
      (lib)
      # keep-sorted start
      getExe
      makeBinPath
      # keep-sorted end
      ;
    inherit
      (pkgs)
      # keep-sorted start
      makeWrapper
      symlinkJoin
      # keep-sorted end
      ;

    piPackage = inputs.pi-nix.packages.${pkgs.stdenv.hostPlatform.system}.coding-agent-bun;

    bunRuntime = symlinkJoin {
      name = "bun-runtime";
      meta.mainProgram = "bun";

      paths = [
        (pkgs.writeShellScriptBin "bun" ''
          if [[ "''${1-}" == install ]]; then
            exec ${getExe pkgs.bun} "$@" --trust
          fi
          exec ${getExe pkgs.bun} "$@"
        '')
      ];

      postBuild = ''
        ln -s ${getExe pkgs.bun} $out/bin/node
      '';
    };

    runtimePackages =
      (with pkgs; [
        # keep-sorted start
        rtk
        wl-clipboard
        # keep-sorted end
      ])
      ++ [bunRuntime]
      ++ attrValues config.programs.pi.mcpServers;
  in {
    imports = [inputs.pi-nix.homeModules.default];

    programs.pi.coding-agent = {
      enable = true;

      # Provide runtime commands used by Pi and its extensions.
      package = symlinkJoin {
        name = "pi-coding-agent-wrapped";
        meta.mainProgram = "pi";
        paths = [piPackage];
        nativeBuildInputs = [makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/pi \
            --prefix PATH : ${makeBinPath runtimePackages}
        '';
      };
      settings.npmCommand = [(getExe bunRuntime)];

      rules = ./instructions.md;
    };

    xdg.desktopEntries.pi = {
      name = "Pi";
      genericName = "AI Coding Assistant";

      exec = let
        pi = getExe config.programs.pi.coding-agent.finalPackage;
        terminalCommand = getExe config.xdg.terminal-exec.package;
      in "${terminalCommand} --title=Pi ${pi}";

      categories = [
        # keep-sorted start
        "ConsoleOnly"
        "Development"
        # keep-sorted end
      ];
    };
  };
}
