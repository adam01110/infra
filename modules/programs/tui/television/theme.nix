{
  flake.modules.homeManager.television = {
    # keep-sorted start
    config,
    pkgs,
    # keep-sorted end
    ...
  }: let
    tomlFormat = pkgs.formats.toml {};

    colors = config.lib.stylix.colors.withHashtag;
  in {
    xdg.configFile."television/themes/".source = with colors;
      tomlFormat.generate "television-stylix.toml" {
        # general
        # keep-sorted start
        background = base00;
        border_fg = base04;
        dimmed_text_fg = base04;
        text_fg = base05;
        # keep-sorted end

        # input
        # keep-sorted start
        input_text_fg = base08;
        result_count_fg = base08;
        # keep-sorted end

        # results
        # keep-sorted start
        match_fg = base08;
        result_line_number_fg = base0A;
        result_name_fg = base0D;
        result_value_fg = base05;
        selection_bg = base01;
        selection_fg = base0B;
        # keep-sorted end

        # preview
        preview_title_fg = base0B;

        # modes
        # keep-sorted start
        action_picker_mode_bg = base0D;
        action_picker_mode_fg = base00;
        channel_mode_bg = base0E;
        channel_mode_fg = base00;
        remote_control_mode_bg = base0C;
        remote_control_mode_fg = base00;
        # keep-sorted end
      };
  };
}
