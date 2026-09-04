{
  flake.modules.nixos.timezone = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      mkIf
      mkMerge
      mkOption
      types
      # keep-sorted end
      ;

    cfgTimezone = config.services.timezone;
  in {
    options.services.timezone = mkOption {
      description = ''
        Configure the system time zone or enable automatic adjustment.
        Set to a time zone string (for example "Europe/Amsterdam") to use a fixed time zone,
        or to "automatic-timezoned" to enable the automatic-timezoned service.
      '';

      type = types.nullOr types.str;
      default = null;
      example = "Europe/Amsterdam";
    };

    config = mkMerge [
      (mkIf (cfgTimezone != null && cfgTimezone != "automatic-timezoned") {
        time.timeZone = cfgTimezone;
      })

      (mkIf (cfgTimezone == "automatic-timezoned") {
        services.automatic-timezoned.enable = true;
      })
    ];
  };
}
