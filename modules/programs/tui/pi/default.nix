{inputs, ...}: {
  flake-file.inputs = {
    # bun2nix 2.1.0 does not provide bun 1.4.x's npm manifest cache
    # (nix-community/bun2nix#77), so offline installs fail. Keep pi on a
    # nixpkgs snapshot that still ships bun 1.3.
    nixpkgs-pi.url = "github:NixOS/nixpkgs/3ed67ec0a4d3c7ab4ae1f04f8ee8df07bfa506a2";

    pi-nix = {
      url = "github:lukasl-dev/pi.nix";
      inputs.nixpkgs.follows = "nixpkgs-pi";
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
    inherit
      (lib)
      # keep-sorted start
      escapeShellArg
      getExe
      makeBinPath
      # keep-sorted end
      ;
    inherit
      (pkgs)
      # keep-sorted start
      makeWrapper
      symlinkJoin
      writeShellScriptBin
      # keep-sorted end
      ;
    inherit (pkgs.stdenv.hostPlatform) system;

    piPackage = inputs.pi-nix.packages.${system}.coding-agent-bun.overrideAttrs (old: {
      patches =
        (old.patches or [])
        ++ [
          ./patches/disable-llama-extension.patch
          ./patches/disable-main-screen-autowrap.patch
          ./patches/reduce-long-session-render-work.patch
        ];
    });
    piSuite = inputs.pi-suite.packages.${system}.default.overrideAttrs (old: {
      postInstall =
        (old.postInstall or "")
        + ''
          substituteInPlace "$out/skills/computer-use-linux/SKILL.md" --replace-fail $'  Use when observing or controlling the local Linux desktop through accessibility\n  trees, screenshots, window targeting, or synthesized input.' $'  Use only when the user explicitly invokes `/computer-use-linux` or explicitly\n  asks to use computer use; never use for ordinary desktop tasks.'
        '';
    });

    jsonFormat = pkgs.formats.json {};

    # opencode-go routes by the x-opencode-session header Pi sends anyway, so its
    # affinity flag stays off; OpenRouter sticky routing uses the documented x-session-id.
    modelsFile = jsonFormat.generate "pi-models.json" {
      providers = {
        opencode-go.compat.sendSessionAffinityHeaders = false;
        openrouter.compat.sendSessionAffinityHeaders = true;
      };
    };

    gpgHome = config.programs.gpg.homedir;
    jjUserConfig = config.sops.templates."jj-user-config".path;

    bunRuntime = symlinkJoin {
      name = "bun-runtime";
      meta.mainProgram = "bun";

      paths = [
        (writeShellScriptBin "bun" ''
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
        openssh
        rtk
        wl-clipboard
        ydotool
        # keep-sorted end
      ])
      ++ [
        # keep-sorted start
        bunRuntime
        config.programs.gpg.package
        # keep-sorted end
      ]
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
            --set GNUPGHOME ${escapeShellArg gpgHome} \
            --set JJ_CONFIG ${escapeShellArg jjUserConfig} \
            --set PI_SUITE_BTW_MODEL "openai-codex gpt-5.6-terra openai-codex-responses" \
            --prefix PATH : ${makeBinPath runtimePackages}
        '';
      };
      models = modelsFile;

      settings = {
        npmCommand = [(getExe bunRuntime)];
        packages = ["${piSuite}"];
      };

      rules = ./instructions.md;
    };
  };
}
