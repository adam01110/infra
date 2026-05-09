{lib}: let
  inherit (builtins) attrNames;
  inherit (lib) concatMapStringsSep;
  inherit (lib.generators) toLua;
in {
  mkYaziUrlEntries = run:
    map (url: {
      inherit url run;
    });

  mkYaziPluginSetup = name: setupOpts: ''
    require("${name}"):setup(${toLua {} setupOpts})
  '';

  mkYaziPluginSetups = pluginSetupOpts:
    concatMapStringsSep "\n" (name: ''
      require("${name}"):setup(${toLua {} pluginSetupOpts.${name}})
    '') (attrNames pluginSetupOpts);
}
