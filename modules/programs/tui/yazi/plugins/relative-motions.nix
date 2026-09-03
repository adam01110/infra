{
  flake.modules.homeManager.yazi = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (builtins) readFile;
    inherit (pkgs) writeTextDir;
    inherit (lib) range;
  in {
    programs.yazi = {
      plugins = {
        relative-motions = {
          package = pkgs.yaziPlugins.relative-motions;
          setup = true;
          settings.show_numbers = "relative_absolute";
        };

        relative-motions-input = writeTextDir "main.lua" (readFile ./relative-motions-input.lua);
      };

      # Avoid the plugin's blocking key reader on Yazi 26.
      keymap.mgr.prepend_keymap =
        (map (digit: {
            on = toString digit;
            run = "plugin relative-motions-input append${toString digit}";
            desc = "Append relative motion count";
          })
          (range 0 9))
        ++ [
          {
            on = "j";
            run = "plugin relative-motions-input down";
            desc = "Move down by relative count";
          }
          {
            on = "k";
            run = "plugin relative-motions-input up";
            desc = "Move up by relative count";
          }
        ];
    };
  };
}
