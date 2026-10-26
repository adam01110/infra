{
  flake.modules.homeManager.yazi = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib.generators) mkLuaInline;

    colors = config.lib.stylix.colors.withHashtag;
  in {
    programs.yazi = {
      plugins.supaline = {
        package = pkgs.nur.repos.adam0.yaziPlugins.supaline;
        setup = true;
        settings = {
          lightness.fg = {
            from = 0.40;
            to = 0.90;
          };
          linemodes.size_mtime = [
            "size"
            (mkLuaInline ''{ "mtime", format = "%Y-%m-%d %H:%M", width = 16 }'')
          ];
        };
      };

      theme.supaline = {
        # keep-sorted start
        mtime = "${colors.base0A} <->";
        size = "${colors.base0D} <->";
        # keep-sorted end
      };
    };
  };
}
