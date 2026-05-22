{inputs, ...}: {
  flake.modules.homeManager.nixhyprBinds = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      concatMap
      concatStringsSep
      filterAttrs
      foldl'
      mkIf
      mkOption
      mkOrder
      types
      # keep-sorted end
      ;

    nixhyprLib = import "${inputs.nixhypr}/lib" {inherit lib;};
    inherit (nixhyprLib) ordering toLua;

    cfg = config.programs.nixhypr;

    bindType = types.submodule {
      options = {
        # keep-sorted start block=yes newline_separated=yes
        action = mkOption {
          description = "Hyprland dispatcher action, such as `window.close` or `focus`.";

          type = types.nullOr types.str;
          default = null;
        };

        args = mkOption {
          description = "Arguments for the action dispatcher.";

          type = types.anything;
          default = null;
        };

        category = mkOption {
          description = "Optional Noctalia keybind-cheatsheet category.";

          type = types.nullOr types.str;
          default = null;
        };

        description = mkOption {
          description = "Optional bind description.";

          type = types.nullOr types.str;
          default = null;
        };

        exec = mkOption {
          description = "Command to execute, as shorthand for `hl.dsp.exec_cmd`.";

          type = types.nullOr types.str;
          default = null;
        };

        keys = mkOption {
          description = "Key combination, such as `[ \"SUPER\" \"q\" ]`.";

          type = types.listOf types.str;
        };

        lua = mkOption {
          description = "Raw Lua dispatcher expression.";

          type = types.nullOr types.str;
          default = null;
        };

        options = mkOption {
          description = "Bind options, such as `repeating`, `locked`, or `description`.";

          type = types.attrsOf types.anything;
          default = {};
        };
        # keep-sorted end
      };
    };

    bindGroupType = types.submodule {
      options = {
        # keep-sorted start block=yes newline_separated=yes
        binds = mkOption {
          description = "Keybindings in this group.";

          type = types.listOf bindType;
          default = [];
        };

        category = mkOption {
          description = "Noctalia keybind-cheatsheet category.";

          type = types.str;
        };
        # keep-sorted end
      };
    };

    cleanAttrs = filterAttrs (_: value: value != null);

    buildDispatcher = bind:
      if bind.exec != null
      then "hl.dsp.exec_cmd(${toLua bind.exec})"
      else if bind.lua != null
      then bind.lua
      else if bind.action != null
      then let
        argsStr =
          if bind.args != null
          then "(${toLua bind.args})"
          else "()";
      in "hl.dsp.${bind.action}${argsStr}"
      else throw "bind must have one of: exec, action, lua";

    buildBindLine = bind: let
      keysStr = concatStringsSep " + " bind.keys;
      dispatcher = buildDispatcher bind;
      bindOptions = cleanAttrs (bind.options // {inherit (bind) description;});
    in
      if bindOptions != {}
      then "hl.bind(${toLua keysStr}, ${dispatcher}, ${toLua bindOptions})"
      else "hl.bind(${toLua keysStr}, ${dispatcher})";

    buildBind = state: bind: let
      categoryChanged = bind.category != null && bind.category != state.category;
      nextIndex =
        if categoryChanged
        then state.index + 1
        else state.index;
      categoryLine =
        if categoryChanged
        then ["-- ${toString nextIndex}. ${bind.category}"]
        else [];
    in {
      category =
        if categoryChanged
        then bind.category
        else state.category;
      index = nextIndex;
      lines = state.lines ++ categoryLine ++ [(buildBindLine bind)];
    };

    groupedBinds = concatMap (group:
      map (bind:
        bind
        // {
          category =
            if bind.category != null
            then bind.category
            else group.category;
        })
      group.binds)
    cfg.bindGroups;

    allBinds = cfg.binds ++ groupedBinds;

    built =
      foldl' buildBind {
        category = null;
        index = 0;
        lines = [];
      }
      allBinds;
  in {
    disabledModules = ["${inputs.nixhypr}/modules/binds.nix"];

    options.programs.nixhypr.binds = mkOption {
      description = "Keybindings.";

      type = types.listOf bindType;
      default = [];
    };

    options.programs.nixhypr.bindGroups = mkOption {
      description = "Grouped keybindings.";

      type = types.listOf bindGroupType;
      default = [];
    };

    config = mkIf (allBinds != []) {
      programs.nixhypr._generatedConfig = mkOrder ordering.binds (concatStringsSep "\n" built.lines);
    };
  };
}
