{
  flake.modules.homeManager.impala = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit (lib) mkIf;

    colors = config.lib.stylix.colors.withHashtag;
  in {
    programs.impala.settings.theme = mkIf config.programs.impala.enable (with colors; {
      # keep-sorted start
      background = base00;
      border = base0D;
      error_color = base08;
      hidden_color = base03;
      info_color = base0B;
      text_color = base05;
      warning_color = base0A;
      # keep-sorted end
    });
  };
}
