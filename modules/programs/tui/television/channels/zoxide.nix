{
  flake.modules.homeManager.television = {
    config,
    lib,
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      escapeShellArgs
      getExe
      # keep-sorted end
      ;

    inherit
      (config.programs.eza)
      # keep-sorted start
      colors
      extraOptions
      icons
      package
      # keep-sorted end
      ;
  in {
    programs.television.channels.zoxide = let
      zoxide = getExe config.programs.zoxide.package;
    in {
      # keep-sorted start block=yes newline_separated=yes
      actions = {
        # keep-sorted start block=yes newline_separated=yes
        cd = {
          description = "Change to the selected directory";
          command = "cd '{}' && $SHELL";
          mode = "execute";
        };

        remove = {
          description = "Remove the selected directory from zoxide";
          command = "${zoxide} remove '{}'";
          mode = "fork";
        };
        # keep-sorted end
      };

      keybindings = {
        # keep-sorted start
        ctrl-d = "actions:remove";
        enter = "actions:cd";
        # keep-sorted end
      };

      metadata = {
        name = "zoxide";
        description = "Browse zoxide directory history";
        requirements = [
          # keep-sorted start
          "eza"
          "zoxide"
          # keep-sorted end
        ];
      };

      preview.command = "${escapeShellArgs (
        ["${getExe package}"]
        ++ extraOptions
        ++ [
          "--color=${colors}"
          "--icons=${icons}"
        ]
      )} '{}'";

      source = {
        # keep-sorted start
        command = "${zoxide} query -l";
        frecency = false;
        no_sort = true;
        # keep-sorted end
      };
      # keep-sorted end
    };
  };
}
