{
  # keep-sorted start
  inputs,
  lib,
  # keep-sorted end
  ...
}: {
  flake.modules.homeManager.television = {
    # keep-sorted start
    osConfig,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (builtins) toJSON;
    inherit (lib) mapAttrs;
    hmLib = import "${inputs.home-manager}/modules/lib/stdlib-extended.nix" lib;
    allowDocUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "vscode-extension-ms-dotnettools-csharp"
      ];

    hmBaseModules = import "${inputs.home-manager}/modules/modules.nix" {
      lib = hmLib;
      inherit pkgs;
      check = false;
    };

    hmDocModule = {
      home = {
        homeDirectory = "/home/nix-search-tv";
        inherit (osConfig.system) stateVersion;
        username = "nix-search-tv";
      };

      nixpkgs.config.allowUnfreePredicate = allowDocUnfreePredicate;
    };

    mkHomeManagerDoc = module: let
      # Evaluate third-party Home Manager modules against Home Manager's full module set.
      homeManagerOptions =
        (hmLib.evalModules {
          modules = hmBaseModules ++ [hmDocModule module];
          class = "homeManager";
        }).options;
    in
      (
        pkgs.nixosOptionsDoc {
          options = removeAttrs homeManagerOptions ["_module"];
          warningsAreErrors = false;
        }
      ).optionsJSON;

    mkNixosDoc = module:
      (
        pkgs.nixosOptionsDoc {
          inherit
            ((
              lib.nixosSystem {
                inherit (pkgs.stdenv.hostPlatform) system;
                modules = [
                  {
                    system.stateVersion = osConfig.system.stateVersion;
                    nixpkgs.config.allowUnfreePredicate = allowDocUnfreePredicate;
                  }
                  module
                ];

                specialArgs = {
                  inherit inputs;
                  modulesPath = "${inputs.nixpkgs}/nixos/modules";
                };
              }
            ))
            options
            ;

          warningsAreErrors = false;
        }
      ).optionsJSON;

    mkFilteredOptionsFile = name: rawDoc: prefixes:
      toString (
        pkgs.runCommandLocal "nix-search-tv-${name}-options" {
          nativeBuildInputs = [pkgs.jq];
          inherit rawDoc;
          prefixesJson = toJSON prefixes;
        } ''
          mkdir -p "$out"

          jq -S \
            --argjson prefixes "$prefixesJson" \
            'with_entries(
              . as $entry
              | select(any(
                $prefixes[];
                . as $prefix
                | ($entry.key == $prefix) or ($entry.key | startswith($prefix + "."))
              ))
            )' \
            "$rawDoc/share/doc/nixos/options.json" > "$out/options.json"
        ''
      )
      + "/options.json";

    # Keep only sources with stable namespaces.
    sources = {
      # Home Manager-backed sources.
      # keep-sorted start block=yes newline_separated=yes
      hylix = {
        rawDoc = mkHomeManagerDoc inputs.hylix.homeManagerModules.default;
        prefixes = ["programs.hylix"];
      };

      nix-flatpak = {
        rawDoc = mkHomeManagerDoc inputs.nix-flatpak.homeManagerModules.nix-flatpak;
        prefixes = ["services.flatpak"];
      };

      nix-index-database = {
        rawDoc = mkHomeManagerDoc inputs.nix-index-database.homeModules.nix-index;
        prefixes = [
          "programs.nix-index-database"
          "programs.nix-index"
        ];
      };

      nixcord = {
        rawDoc = mkHomeManagerDoc inputs.nixcord.homeModules.nixcord;
        prefixes = ["programs.nixcord"];
      };

      noctalia = {
        rawDoc = mkHomeManagerDoc inputs.noctalia.homeModules.default;
        prefixes = ["programs.noctalia-shell"];
      };

      nvf = {
        rawDoc = mkHomeManagerDoc inputs.nvf.homeManagerModules.default;
        prefixes = ["programs.nvf"];
      };

      overzicht = {
        rawDoc = mkHomeManagerDoc inputs.overzicht.homeModules.default;
        prefixes = ["programs.overzicht"];
      };

      sops-nix-home-manager = {
        rawDoc = mkHomeManagerDoc inputs.sops-nix.homeManagerModules.sops;
        prefixes = ["sops"];
      };

      spicetify-nix = {
        rawDoc = mkHomeManagerDoc inputs.spicetify-nix.homeManagerModules.spicetify;
        prefixes = ["programs.spicetify"];
      };

      stylix-home-manager = {
        rawDoc = mkHomeManagerDoc inputs.stylix.homeModules.stylix;
        prefixes = ["stylix"];
      };

      zen-browser = {
        rawDoc = mkHomeManagerDoc inputs.zen-browser.homeModules.beta;
        prefixes = ["programs.zen-browser"];
      };
      # keep-sorted end

      # NixOS-backed sources.
      # keep-sorted start block=yes newline_separated=yes
      disko = {
        rawDoc = mkNixosDoc inputs.disko.nixosModules.disko;
        prefixes = ["disko"];
      };

      home-manager-nixos = {
        rawDoc = mkNixosDoc inputs.home-manager.nixosModules.home-manager;
        prefixes = ["home-manager"];
      };

      lanzaboote = {
        rawDoc = mkNixosDoc inputs.lanzaboote.nixosModules.lanzaboote;
        prefixes = ["boot.lanzaboote"];
      };

      sops-nix = {
        rawDoc = mkNixosDoc inputs.sops-nix.nixosModules.sops;
        prefixes = ["sops"];
      };

      stylix = {
        rawDoc = mkNixosDoc inputs.stylix.nixosModules.stylix;
        prefixes = ["stylix"];
      };
      # keep-sorted end
    };

    optionsFile = mapAttrs (name: value: mkFilteredOptionsFile name value.rawDoc value.prefixes) sources;
  in {
    programs.nix-search-tv = {
      enable = true;
      enableTelevisionIntegration = true;

      settings = {
        # Keep builtin upstream indexes under `indexes`.
        indexes = [
          # keep-sorted start
          "home-manager"
          "nixos"
          "nixpkgs"
          "noogle"
          "nur"
          # keep-sorted end
        ];

        # keep-sorted start

        # Disable the waiting message that never goes away.
        enable_waiting_message = false;
        # Add custom docs sources through `options_file`; they are not valid `indexes` entries.
        experimental.options_file = optionsFile;
        # keep-sorted end
      };
    };
  };
}
