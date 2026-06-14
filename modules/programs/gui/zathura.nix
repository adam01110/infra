{
  flake.modules.homeManager.zathura = {config, ...}: let
    sansSerifFont = config.stylix.fonts.sansSerif.name;
  in {
    programs.zathura = {
      enable = true;

      options = {
        # Enable recoloring of documents.
        # keep-sorted start
        recolor = true;
        recolor-keephue = true;
        # keep-sorted end

        # keep-sorted start block=yes newline_separated=yes
        font = sansSerifFont;

        # Use the system clipboard for text selection.
        selection-clipboard = "clipboard";

        # Show hidden files for complete filesystem access.
        show-hidden = true;
        # keep-sorted end
      };
    };
  };
}
