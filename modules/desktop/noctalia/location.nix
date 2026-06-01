{
  flake.modules.homeManager.noctalia = {
    # keep-sorted start
    config,
    lib,
    osConfig,
    vars,
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
    inherit (vars) noctaliaFirstDayOfWeek;

    cfgLocation = config.programs.noctalia-shell.location.source;
  in {
    # Control whether Noctalia reads weather data from autolocation or sops.
    options.programs.noctalia-shell.location.source = mkOption {
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
        programs.noctalia-shell.settings.location = {
          # keep-sorted start
          analogClockInCalendar = true;
          autoLocate = true;
          firstDayOfWeek = noctaliaFirstDayOfWeek;
          showCalendarWeather = false;
          showWeekNumberInCalendar = true;
          # keep-sorted end
        };
      }

      # Read the desktop weather location from sops at runtime.
      (let
        hostname = osConfig.networking.hostName;
      in
        mkIf (cfgLocation == "sops") {
          sops.secrets."noctalia/location/${hostname}" = {};
          programs.noctalia-shell = {
            # keep-sorted start
            settings.location.autoLocate = mkForce false;
            systemd.locationFile = config.sops.secrets."noctalia/location/${hostname}".path;
            # keep-sorted end
          };
        })
    ];
  };
}
