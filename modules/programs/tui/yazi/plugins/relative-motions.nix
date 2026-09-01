{
  flake.modules.homeManager.yazi = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      concatMap
      range
      stringToCharacters
      # keep-sorted end
      ;
  in {
    programs.yazi = {
      plugins.relative-motions = {
        package = pkgs.yaziPlugins.relative-motions;
        setup = true;
        settings.show_numbers = "relative_absolute";
      };

      # Avoid the plugin's blocking key reader on Yazi 26.
      keymap.mgr.prepend_keymap = concatMap (step: let
        keys = stringToCharacters (toString step);
      in [
        {
          on = keys ++ ["j"];
          run = "arrow ${toString step}";
          desc = "Move down ${toString step} entries";
        }
        {
          on = keys ++ ["k"];
          run = "arrow -${toString step}";
          desc = "Move up ${toString step} entries";
        }
      ]) (range 1 99);
    };
  };
}
