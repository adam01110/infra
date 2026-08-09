{
  flake.modules.homeManager.noctalia = {
    # keep-sorted start
    config,
    lib,
    osConfig,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      mkForce
      mkIf
      mkMerge
      mkOption
      types
      # keep-sorted end
      ;
    inherit (config.lib.file) mkOutOfStoreSymlink;

    cfgLocation = config.programs.noctalia.location.source;
  in {
    options.programs.noctalia.location.source = mkOption {
      description = ''
        Configure the Noctalia location source.
        Set to "autolocate" to use automatic location detection, or to "sops"
        to read the location from the `noctalia/location` secret.
      '';

      type = types.nullOr (types.enum [
        # keep-sorted start
        "autolocate"
        "sops"
        # keep-sorted end
      ]);
      default = "autolocate";
    };

    config = mkMerge [
      {
        programs.noctalia.settings = {
          location.auto_locate = true;

          weather = {
            # keep-sorted start
            effects = true;
            enabled = true;
            unit = "metric";
            # keep-sorted end
          };
        };
      }

      # Loads the private location as a later merged config fragment.
      (let
        hostname = osConfig.networking.hostName;
        secretName = "noctalia/location/${hostname}";
        templateName = "noctalia-location";
      in
        mkIf (cfgLocation == "sops") {
          programs.noctalia.settings.location.auto_locate = mkForce false;

          sops = {
            secrets.${secretName} = {};
            templates.${templateName}.content = ''
              [location]
              address = "${config.sops.placeholder.${secretName}}"
              auto_locate = false
            '';
          };

          xdg.configFile."noctalia/location.toml".source = mkOutOfStoreSymlink config.sops.templates.${templateName}.path;
        })
    ];
  };
}
