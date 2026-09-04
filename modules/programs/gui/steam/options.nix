{
  flake.modules.homeManager.steam = {
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
      escapeShellArg
      getExe
      literalExpression
      mapAttrs'
      mkEnableOption
      mkIf
      mkOption
      nameValuePair
      optionalAttrs
      types
      # keep-sorted end
      ;
    inherit (lib.hm.dag) entryAfter;
    inherit (pkgs) jq;
    inherit (pkgs.python3Packages) json5 toPythonApplication;

    cfg = config.programs.steam.millennium;
    jsonFormat = pkgs.formats.json {};
    json5Application = toPythonApplication json5;

    mergeConfig = empty: jqOperation: path: staticSettings: ''
      mkdir -p "$(dirname ${escapeShellArg path})"
      if [ ! -e ${escapeShellArg path} ]; then
        printf '%s\n' ${escapeShellArg empty} > ${escapeShellArg path}
      fi

      dynamic="$(${getExe json5Application} --as-json ${escapeShellArg path} 2>/dev/null || printf '%s\n' ${escapeShellArg empty})"
      static="$(cat ${escapeShellArg staticSettings})"
      settings="$(${getExe jq} -n ${escapeShellArg jqOperation} --argjson dynamic "$dynamic" --argjson static "$static")"
      printf '%s\n' "$settings" > ${escapeShellArg path}
    '';
  in {
    options.programs.steam.millennium = {
      enable = mkEnableOption "Millennium configuration";

      activeTheme = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "material";
        description = ''
          Name of the active theme. This must match an attribute in
          `programs.steam.millennium.themes`, or be null to use Steam's default theme.
        '';
      };

      themes = mkOption {
        type = types.attrsOf (types.oneOf [types.package types.path]);
        default = {};
        example = literalExpression ''
          {
            material = pkgs.millennium-material-theme;
          }
        '';
        description = ''
          Theme packages to install in `$XDG_DATA_HOME/Steam/millennium/themes`.
        '';
      };

      plugins = mkOption {
        type = types.attrsOf (types.oneOf [types.package types.path]);
        default = {};
        example = literalExpression ''
          {
            example = pkgs.millennium-example-plugin;
          }
        '';
        description = ''
          Plugin packages to install in `$XDG_DATA_HOME/millennium/plugins`.
        '';
      };

      config = mkOption {
        inherit (jsonFormat) type;
        default = {};
        example = literalExpression ''
          {
            themes.conditions.material.Color = "Catppuccin";
          }
        '';
        description = ''
          Configuration merged into `$XDG_CONFIG_HOME/millennium/config.json`.
        '';
      };

      mutableConfig = mkOption {
        type = types.bool;
        default = true;
        example = false;
        description = "Whether Millennium may update its configuration file.";
      };
    };

    config = let
      settings =
        cfg.config
        // optionalAttrs (cfg.activeTheme != null) {
          themes.activeTheme = cfg.activeTheme;
        };
    in
      mkIf cfg.enable {
        home.activation.millenniumSettings = mkIf (cfg.mutableConfig && settings != {}) (
          entryAfter ["linkGeneration"] (
            mergeConfig "{}" "$dynamic * $static" "${config.xdg.configHome}/millennium/config.json" (
              jsonFormat.generate "millennium-user-settings" settings
            )
          )
        );

        xdg.dataFile =
          mapAttrs' (
            name: source: nameValuePair "Steam/millennium/themes/${name}" {inherit source;}
          )
          cfg.themes
          // mapAttrs' (
            name: source: nameValuePair "millennium/plugins/${name}" {inherit source;}
          )
          cfg.plugins;
      };
  };
}
