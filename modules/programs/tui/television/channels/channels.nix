{
  flake.modules.homeManager.television = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;

    inherit (config.xdg) configHome;

    # keep-sorted start
    bat = getExe pkgs.bat;
    tv = getExe pkgs.television;
    # keep-sorted end
  in {
    programs.television.channels.channels = {
      # keep-sorted start block=yes newline_separated=yes
      actions.channel-enter = {
        description = "Enter a television channel";
        command = "${tv} {}";
        mode = "execute";
      };

      keybindings.enter = "actions:channel-enter";

      metadata = {
        name = "channels";
        description = "Select a television channel";
        requirements = [
          # keep-sorted start
          "bat"
          "tv"
          # keep-sorted end
        ];
      };

      preview.command = "${bat} -pn --color always ${configHome}/television/cable/**/{}.toml";

      source.command = "${tv} list-channels";
      # keep-sorted end
    };
  };
}
