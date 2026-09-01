{inputs, ...}: {
  flake-file.inputs = {
    pi-nix = {
      url = "github:lukasl-dev/pi.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pi-suite = {
      url = "git+https://tangled.org/did:plc:yyq2r4sag7vtnnd36rvsnnuq";
      inputs = {
        # keep-sorted start
        flake-parts.follows = "flake-parts";
        import-tree.follows = "import-tree";
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
        # keep-sorted end
      };
    };
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
    inherit (pkgs.stdenv.hostPlatform) system;
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

    piPackage = inputs.pi-nix.packages.${system}.coding-agent-bun.overrideAttrs (old: {
      patches = (old.patches or []) ++ [./patches/disable-llama-extension.patch];
    });
    piSuite = inputs.pi-suite.packages.${system}.default;

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
            --set PI_SUITE_BTW_MODEL "openai-codex gpt-5.6-terra openai-codex-responses" \
            --prefix PATH : ${makeBinPath runtimePackages}
        '';
      };
      settings = {
        npmCommand = [(getExe bunRuntime)];
        packages = ["${piSuite}"];
      };

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
