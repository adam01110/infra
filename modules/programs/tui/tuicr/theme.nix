{
  flake.modules.homeManager.tuicr = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib.self) blendHex;

    colors = config.lib.stylix.colors.withHashtag;
    tomlFormat = pkgs.formats.toml {};
  in {
    xdg.configFile."tuicr/themes/stylix.tmTheme".source =
      config.programs.bat.themes."base16-stylix".src;

    xdg.configFile."tuicr/themes/stylix.toml".source = with colors;
      tomlFormat.generate "tuicr-stylix-theme.toml" {
        # keep-sorted start
        bg_highlight = base01;
        border_focused = base0D;
        border_unfocused = base02;
        branch_name = base0E;
        comment_issue = base08;
        comment_note = base0D;
        comment_praise = base0B;
        comment_suggestion = base0C;
        cursor_color = base0A;
        cursor_line_bg = base01;
        diff_add = base0B;
        diff_add_bg = blendHex 22 base00 base0B;
        diff_context = base05;
        diff_del = base08;
        diff_del_bg = blendHex 22 base00 base08;
        diff_hunk_header = base0D;
        expanded_context_fg = base03;
        fg_dim = base03;
        fg_primary = base05;
        fg_secondary = base04;
        file_added = base0B;
        file_deleted = base08;
        file_modified = base0A;
        file_renamed = base0E;
        help_indicator = base04;
        message_error_bg = base08;
        message_error_fg = base00;
        message_info_bg = base0D;
        message_info_fg = base00;
        message_warning_bg = base0A;
        message_warning_fg = base00;
        mode_bg = base0D;
        mode_fg = base00;
        panel_bg = base00;
        pending = base0A;
        reviewed = base0B;
        status_bar_bg = base01;
        syntax_add_bg = blendHex 22 base00 base0B;
        syntax_del_bg = blendHex 22 base00 base08;
        syntax_theme = "stylix.tmTheme";
        update_badge_bg = base0A;
        update_badge_fg = base00;
        # keep-sorted end
      };
  };
}
