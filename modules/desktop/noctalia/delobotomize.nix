{inputs, ...}: {
  flake.modules.homeManager.noctalia = {
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
      mkForce
      mkOption
      optionals
      types
      # keep-sorted end
      ;

    inherit (pkgs.stdenv.hostPlatform) system;

    cfg = config.programs.noctalia-shell;

    basePackage =
      if cfg.packageOverrides.package != null
      then cfg.packageOverrides.package
      else inputs.noctalia.packages.${system}.default;

    overrideArgs = removeAttrs cfg.packageOverrides ["package"];
    locationFileEnv = optionals (cfg.systemd.locationFile != null) ["NOCTALIA_LOCATION_FILE=${cfg.systemd.locationFile}"];
  in {
    options = {
      programs.noctalia-shell = {
        # keep-sorted start block=yes newline_separated=yes
        # Keep a base package and overrides for local patches.
        packageOverrides = mkOption {
          description = "Override arguments applied to the base package.";

          type = types.submodule {
            # keep-sorted start block=yes newline_separated=yes
            freeformType = types.attrs;

            # Add runtime tools directly to the wrapped shell package path.
            options.extraPackages = mkOption {
              description = "Additional runtime packages prepended to the shell wrapper PATH.";

              type = types.listOf types.package;
              default = [];
            };

            options.package = mkOption {
              description = "Optional base package used before applying local patches.";

              type = types.nullOr types.package;
              default = null;
            };
            # keep-sorted end
          };

          default = {};
        };

        # Keep gui settings writes outside the nix store.
        systemd = {
          # keep-sorted start block=yes newline_separated=yes
          locationFile = mkOption {
            description = ''
              Optional file whose trimmed contents override `settings.location.name` before the shell starts.
              Point this at a sops secret path to keep the location out of the nix store.
            '';

            type = types.nullOr types.path;
            default = null;
          };

          mutableRuntimeSettings = mkOption {
            description = "Whether noctalia-shell creates a gui-settings.json to store setting changes made within the GUI at runtime.";

            type = types.bool;
            default = true;
          };
          # keep-sorted end
        };
        # keep-sorted end
      };
    };

    config = {
      programs.noctalia-shell = {
        # keep-sorted start block=yes newline_separated=yes
        # Restore gui-settings fallback behavior and add a location file override.
        package = mkForce ((basePackage.override overrideArgs).overrideAttrs (old: {
          patches =
            (old.patches or [])
            ++ [
              # keep-sorted start
              ./patches/noctalia-launcher-ipc.patch
              ./patches/noctalia-location-override.patch
              ./patches/noctalia-settings-fallback.patch
              # keep-sorted end
            ];
        }));
        # keep-sorted end
      };

      # Pass through runtime settings paths and optional location override file.
      systemd.user.services.noctalia-shell.Service.Environment = let
        cfgEnv = config.programs.noctalia-shell.systemd;
      in
        optionals (cfgEnv.enable && cfgEnv.mutableRuntimeSettings) ["NOCTALIA_SETTINGS_FALLBACK=%h/.config/noctalia/gui-settings.json"]
        ++ optionals cfgEnv.enable locationFileEnv;
    };
  };
}
