{
  # keep-sorted start
  inputs,
  # keep-sorted end
  ...
}: {
  flake-file.inputs.nixcord = {
    url = "github:kaylorben/nixcord";
    inputs.flake-parts.follows = "flake-parts";
  };

  flake.modules.homeManager.discord = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) mkForce;
    inherit (lib.hm) dag;

    settingsPath = "${config.xdg.configHome}/equibop/settings/settings.json";
    settingsSource = config.home.file.${settingsPath}.source;
  in {
    imports = [inputs.nixcord.homeModules.nixcord];

    # keep-sorted start block=yes newline_separated=yes
    # Let Equibop persist runtime changes to its generated settings.
    home = {
      file.${settingsPath}.enable = mkForce false;

      activation.nixcordEquibopWritableSettings = dag.entryAfter ["writeBoundary"] ''
        settings=${lib.escapeShellArg settingsPath}
        if [[ -L "$settings" ]]; then
          rm "$settings"
        fi
        ${lib.getExe' pkgs.coreutils "install"} -Dm644 ${lib.escapeShellArg settingsSource} "$settings"
      '';
    };

    programs.nixcord = {
      enable = true;
      discord.enable = false;

      equibop = {
        enable = true;
        configDir = "${config.xdg.configHome}/equibop";
      };
    };
    # keep-sorted end
  };
}
