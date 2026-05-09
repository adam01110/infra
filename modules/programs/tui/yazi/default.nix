{
  flake.modules.homeManager.yazi = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (builtins) readFile;
    inherit
      (lib)
      # keep-sorted start
      mkOption
      types
      # keep-sorted end
      ;
    inherit (lib.self) mkYaziPluginSetups;

    cfg = config.programs.yazi;
  in {
    options.programs.yazi.pluginSetupOpts = mkOption {
      type = types.attrsOf types.anything;
      default = {};
      description = "Yazi plugin setup options rendered into init.lua.";
    };

    # Yazi tui file manager.
    programs.yazi = {
      enable = true;

      initLua = pkgs.writeText "yazi-init.lua" ''
        ${readFile ./init.lua}
        ${mkYaziPluginSetups cfg.pluginSetupOpts}
      '';
      shellWrapperName = "y";
    };
  };
}
