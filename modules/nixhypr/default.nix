{inputs, ...}: {
  flake.modules.homeManager.nixhypr = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      concatStringsSep
      mkEnableOption
      mkIf
      mkOption
      types
      # keep-sorted end
      ;

    cfg = config.programs.nixhypr;
  in {
    imports = ["${inputs.nixhypr}/modules"];

    options.programs.nixhypr = {
      enable = mkEnableOption "nixhypr hyprland lua config generator";

      extraLuaSnippets = mkOption {
        description = "Lua snippets concatenated into nixhypr's extraLua.";

        type = types.listOf types.lines;
        default = [];
      };
    };

    config = mkIf cfg.enable {
      wayland.windowManager.hyprland = {
        configType = "lua";
        extraConfig = cfg._generatedConfig;
      };

      programs.nixhypr.extraLua = concatStringsSep "\n" cfg.extraLuaSnippets;
    };
  };
}
