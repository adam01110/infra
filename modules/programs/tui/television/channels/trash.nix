{
  flake.modules.homeManager.television = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe';

    # keep-sorted start
    echo = getExe' pkgs.coreutils "echo";
    trash-empty = getExe' pkgs.trash-cli "trash-empty";
    trash-list = getExe' pkgs.trash-cli "trash-list";
    trash-restore = getExe' pkgs.trash-cli "trash-restore";
    # keep-sorted end
  in {
    programs.television.channels.trash = {
      # keep-sorted start block=yes newline_separated=yes
      actions = {
        # keep-sorted start block=yes newline_separated=yes
        empty = {
          description = "Empty the entire trash";
          command = trash-empty;
          mode = "execute";
        };

        restore = {
          description = "Restore the selected trashed file";
          command = "${echo} '{split: :1..}' | ${trash-restore}";
          mode = "execute";
        };
        # keep-sorted end
      };

      metadata = {
        name = "trash";
        description = "Browse and restore trashed files";
        requirements = [
          # keep-sorted start
          "trash-empty"
          "trash-list"
          "trash-restore"
          # keep-sorted end
        ];
      };

      preview.command = "${echo} '{}'";

      source = {
        # keep-sorted start
        command = "${trash-list} 2>/dev/null";
        frecency = false;
        no_sort = true;
        # keep-sorted end
      };

      ui.preview_panel.size = 30;
      # keep-sorted end
    };
  };
}
