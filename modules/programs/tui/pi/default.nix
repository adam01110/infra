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

    gpgHome = config.programs.gpg.homedir;
    jjUserConfig = config.sops.templates."jj-user-config".path;
    piPackage = inputs.pi-nix.packages.${system}.coding-agent-bun.overrideAttrs (old: {
      patches = (old.patches or []) ++ [./patches/disable-llama-extension.patch];
    });
    piSuite = inputs.pi-suite.packages.${system}.default;

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

      jail = {
        enable = true;
        permissions = combinators:
          with combinators; [
            # Retain network and desktop integration without exposing the host
            # filesystem that backs them.
            network
            pipewire
            wayland
            (dbus {
              talk = [
                # keep-sorted start
                "org.a11y.Bus"
                "org.freedesktop.DBus"
                "org.freedesktop.portal.*"
                # keep-sorted end
              ];
            })

            # Make Nix inputs and profiles visible without permitting changes.
            (readonly "/nix/store")
            (try-readonly "/etc/profiles")
            (try-readonly "/run/current-system")
            (try-readonly (noescape "~/.local/state/nix/profile"))
            (try-readonly (noescape "~/.nix-profile"))

            # Keep project roots writable independently of the launch
            # directory.
            (try-readwrite "${config.home.homeDirectory}/Infra")
            (try-readwrite "${config.home.homeDirectory}/Projects")

            # Expose Jujutsu identity and signing policy without private key
            # files.
            (readonly jjUserConfig)
            (try-readonly "${gpgHome}/pubring.kbx")
            (try-readonly "${gpgHome}/trustdb.gpg")
            (add-runtime ''
              gpgAgentSocket="$(${config.programs.gpg.package}/bin/gpgconf --homedir ${escapeShellArg gpgHome} --list-dirs agent-socket)"
              if [[ -S "$gpgAgentSocket" ]]; then
                RUNTIME_ARGS+=(--bind "$gpgAgentSocket" "$gpgAgentSocket")
              fi
            '')

            # Provide SSH host configuration and agent access without key
            # files.
            (try-readonly (noescape "~/.ssh/config"))
            (try-readonly (noescape "~/.ssh/known_hosts"))
            (try-readonly (noescape "~/.ssh/known_hosts2"))
            (add-runtime ''
              if [[ -S "''${SSH_AUTH_SOCK-}" ]]; then
                RUNTIME_ARGS+=(--bind "$SSH_AUTH_SOCK" "$SSH_AUTH_SOCK")
              fi
            '')

            # Preserve the state and sockets required by Pi extensions.
            (try-readwrite (noescape "~/.cc-safety-net"))
            (try-readwrite (noescape "\"$XDG_RUNTIME_DIR/.ydotool_socket\""))
            (try-readwrite (noescape "\"$XDG_RUNTIME_DIR/at-spi\""))
            (try-readwrite (noescape "\"$XDG_RUNTIME_DIR/hypr\""))
            (try-readwrite "/nix/var/nix/daemon-socket")

            # Forward only environment values needed by runtime tools.
            (try-fwd-env "HYPRLAND_INSTANCE_SIGNATURE")
            (try-fwd-env "SSH_AUTH_SOCK")
            (try-fwd-env "XDG_CURRENT_DESKTOP")
            (try-fwd-env "XDG_RUNTIME_DIR")
            (try-fwd-env "XDG_SESSION_DESKTOP")
            (fwd-env "PATH")

            # Apply last so the current working tree stays writable when it is
            # nested under an otherwise read-only path such as ~/Infra.
            mount-cwd
          ];
      };

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
      settings = {
        npmCommand = [(getExe bunRuntime)];
        packages = ["${piSuite}"];
      };

      rules = ./instructions.md;
    };
  };
}
