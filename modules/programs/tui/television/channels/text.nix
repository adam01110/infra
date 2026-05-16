{
  flake.modules.homeManager.television = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;
  in {
    programs.television.channels.text = {
      # keep-sorted start block=yes newline_separated=yes
      actions.edit = {
        description = "Open file in editor at line";
        command = "$EDITOR '+{strip_ansi|split:\\::1}' '{strip_ansi|split:\\::0}'";
        mode = "execute";
      };

      metadata = {
        name = "text";
        description = "A channel to find and select text from files";
        requirements = [
          # keep-sorted start
          "bat"
          "file"
          "rg"
          # keep-sorted end
        ];
      };

      preview = {
        command = "${getExe pkgs.text-preview} '{strip_ansi|split:\\::0}'";
        offset = "{strip_ansi|split:\\::1}";
        env.BAT_THEME = "ansi";
      };

      source = {
        # keep-sorted start block=yes
        ansi = true;
        command = [
          "rg . --no-heading --line-number --colors 'match:fg:white' --colors 'path:fg:blue' --color=always"
          "rg . --no-heading --line-number --hidden --colors 'match:fg:white' --colors 'path:fg:blue' --color=always"
        ];
        output = "{strip_ansi|split:\\::..2}";
        # keep-sorted end
      };

      ui.preview_panel.header = "{strip_ansi|split:\\::..2}";
      # keep-sorted end
    };
  };
}
