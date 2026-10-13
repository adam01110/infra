{
  flake.modules.homeManager.xdgApplications = {
    lib,
    pkgs,
    ...
  }: let
    inherit
      (lib.self)
      # keep-sorted start
      mimeAppDefaults
      mimeAppEntries
      # keep-sorted end
      ;
    inherit (pkgs) runCommand;
  in {
    xdg.mimeApps.associations.added = mimeAppDefaults (
      # keep-sorted start block=yes
      (mimeAppEntries "application" "ai.storyteller.wordcraft.desktop" [
        # keep-sorted start
        "msword"
        "msword-template"
        "rtf"
        "vnd.ms-word.document.macroEnabled.12"
        "vnd.ms-word.template.macroEnabled.12"
        "vnd.oasis.opendocument.text"
        "vnd.openxmlformats-officedocument.wordprocessingml.document"
        "vnd.openxmlformats-officedocument.wordprocessingml.template"
        # keep-sorted end
      ])
      ++ (mimeAppEntries "application" "ai.storyteller.deckcraft.desktop" [
        # keep-sorted start
        "vnd.openxmlformats-officedocument.presentationml.presentation"
        "vnd.openxmlformats-officedocument.presentationml.slideshow"
        "vnd.openxmlformats-officedocument.presentationml.template"
        "x-deckcraft"
        # keep-sorted end
      ])
      ++ (mimeAppEntries "application" "ai.storyteller.gridcraft.desktop" [
        # keep-sorted start
        "vnd.ms-excel.sheet.macroEnabled.12"
        "vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        # keep-sorted end
      ])
      ++ (mimeAppEntries "text" "ai.storyteller.gridcraft.desktop" [
        # keep-sorted start
        "csv"
        "tab-separated-values"
        # keep-sorted end
      ])
      ++ (mimeAppEntries "text" "ai.storyteller.wordcraft.desktop" [
        "rtf"
      ])
      # keep-sorted end
    );

    xdg.mimeApps.defaultApplications = {
      # keep-sorted start
      "application/x-deckcraft" = "ai.storyteller.deckcraft.desktop";
      "text/rtf" = "zaread.desktop";
      "text/tab-separated-values" = "ai.storyteller.gridcraft.desktop";
      # keep-sorted end
    };

    home.packages = [
      (runCommand "deckcraft-mime" {nativeBuildInputs = [pkgs.shared-mime-info];} ''
        mkdir -p "$out/share/mime/packages"
        cat > "$out/share/mime/packages/deckcraft.xml" <<'EOF'
        <?xml version="1.0" encoding="UTF-8"?>
        <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
          <mime-type type="application/x-deckcraft">
            <comment>DeckCraft presentation</comment>
            <glob pattern="*.deckcraft"/>
          </mime-type>
        </mime-info>
        EOF
        update-mime-database "$out/share/mime"
      '')
    ];
  };
}
