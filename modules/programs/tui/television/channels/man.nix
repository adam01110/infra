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

    man = getExe config.programs.man.package;
  in {
    programs.television.channels.man = {
      # keep-sorted start block=yes newline_separated=yes
      actions.open = {
        description = "Open the selected man page in the system pager";
        command = "${man} '{0}'";
        mode = "execute";
      };

      keybindings.enter = "actions:open";

      metadata = {
        name = "man";
        description = "Browse and preview system manual pages";
        requirements = [
          # keep-sorted start
          "bat"
          "man"
          "sed"
          # keep-sorted end
        ];
      };

      preview = {
        command = "${getExe pkgs.man-preview} '{0}'";
        env.MANWIDTH = "80";
      };

      source.command = "${man} -k .";

      ui.preview_panel.header = "{0}";
      # keep-sorted end
    };
  };
}
