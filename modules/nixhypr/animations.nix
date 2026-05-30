{inputs, ...}: {
  flake.modules.homeManager.nixhypr = {
    lib,
    config,
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      concatStringsSep
      filterAttrs
      mapAttrsToList
      mkIf
      mkMerge
      mkOption
      mkOrder
      optionalAttrs
      types
      # keep-sorted end
      ;

    nixhyprLib = import "${inputs.nixhypr}/lib" {inherit lib;};
    inherit (nixhyprLib) ordering toLua;

    cfg = config.programs.nixhypr;

    curveType = types.submodule {
      options = {
        type = mkOption {
          description = "Curve type.";
          type = types.enum ["bezier" "spring"];
        };

        points = mkOption {
          default = null;
          description = "Bezier control points [x1, y1, x2, y2].";
          type = types.nullOr (types.listOf types.float);
        };

        mass = mkOption {
          default = null;
          description = "Spring mass.";
          type = types.nullOr (types.either types.int types.float);
        };

        stiffness = mkOption {
          default = null;
          description = "Spring stiffness.";
          type = types.nullOr (types.either types.int types.float);
        };

        dampening = mkOption {
          default = null;
          description = "Spring dampening.";
          type = types.nullOr (types.either types.int types.float);
        };
      };
    };

    animationType = types.submodule {
      options = {
        leaf = mkOption {
          description = "Animation leaf name.";
          type = types.str;
        };

        enabled = mkOption {
          default = true;
          description = "Whether this animation is enabled.";
          type = types.bool;
        };

        speed = mkOption {
          default = null;
          description = "Animation speed.";
          type = types.nullOr (types.either types.int types.float);
        };

        bezier = mkOption {
          default = null;
          description = "Name of a bezier curve to use.";
          type = types.nullOr types.str;
        };

        spring = mkOption {
          default = null;
          description = "Name of a spring curve to use.";
          type = types.nullOr types.str;
        };

        style = mkOption {
          default = null;
          description = "Animation style.";
          type = types.nullOr types.str;
        };
      };
    };

    buildCurve = name: curve: let
      table =
        if curve.type == "bezier"
        then {
          type = "bezier";
          points = [
            [
              (builtins.elemAt curve.points 0)
              (builtins.elemAt curve.points 1)
            ]
            [
              (builtins.elemAt curve.points 2)
              (builtins.elemAt curve.points 3)
            ]
          ];
        }
        else
          filterAttrs (_: value: value != null) {
            inherit (curve) dampening mass stiffness type;
          };
    in "hl.curve(\"${name}\", ${toLua table})";

    curveLines = concatStringsSep "\n" (mapAttrsToList buildCurve cfg.animations.curves);

    buildAnimation = animation: let
      table =
        {inherit (animation) enabled leaf;}
        // optionalAttrs (animation.speed != null) {inherit (animation) speed;}
        // optionalAttrs (animation.bezier != null) {inherit (animation) bezier;}
        // optionalAttrs (animation.spring != null) {inherit (animation) spring;}
        // optionalAttrs (animation.style != null) {inherit (animation) style;};
    in "hl.animation(${toLua table})";

    animationLines = concatStringsSep "\n" (map buildAnimation cfg.animations.animations);
  in {
    disabledModules = ["${inputs.nixhypr}/modules/animations.nix"];

    options.programs.nixhypr.animations = {
      curves = mkOption {
        default = {};
        description = "Named animation curves.";
        type = types.attrsOf curveType;
      };

      animations = mkOption {
        default = [];
        description = "Animation configurations.";
        type = types.listOf animationType;
      };
    };

    config = mkMerge [
      (mkIf (cfg.animations.curves != {}) {
        programs.nixhypr._generatedConfig = mkOrder ordering.curves curveLines;
      })
      (mkIf (cfg.animations.animations != []) {
        programs.nixhypr._generatedConfig = mkOrder ordering.animations animationLines;
      })
    ];
  };
}
