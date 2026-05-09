{
  flake.modules.homeManager.yazi = {
    # keep-sorted start
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (lib) getExe;
    inherit (lib.self) mkYaziUrlEntries;

    piper = "faster-piper --";
    systemdStatusPreview = getExe pkgs.systemd-status-preview;
    usePreloader = "faster-piper --rely-on-preloader";
  in {
    programs.yazi = {
      # keep-sorted start block=yes newline_separated=yes
      plugins.faster-piper = pkgs.nur.repos.adam0.yaziPlugins.faster-piper;

      # Use faster-piper for markdown, archives, compressed text, sqlite, and systemd previews.
      settings.plugin = {
        # keep-sorted start newline_separated=yes
        # Preloaders that render content for faster-piper.
        prepend_preloaders =
          mkYaziUrlEntries "${piper} CLICOLOR_FORCE=1 glow -w=$w -s=dark -- \"$1\"" ["*.md"]
          ++
          # Archive files.
          mkYaziUrlEntries "${piper} tar tf \"$1\"" ["*.tar*"]
          ++
          # Compressed text files.
          mkYaziUrlEntries "${piper} gzip -dc \"$1\"" ["*.txt.gz"]
          ++
          # SQLite database files.
          mkYaziUrlEntries ''${piper} sqlite3 -readonly "$1" ".schema --indent"'' ["*.db" "*.sqlite" "*.sqlite3"]
          ++
          # Systemd service files.
          mkYaziUrlEntries ''${piper} ${systemdStatusPreview} --from-path "$1"'' ["*/systemd/*"];

        # Previewers routed through faster-piper.
        prepend_previewers =
          mkYaziUrlEntries usePreloader ["*.md"]
          ++
          # Archive files.
          mkYaziUrlEntries "${usePreloader} --format=url" ["*.tar*"]
          ++
          # Compressed text files.
          mkYaziUrlEntries usePreloader ["*.txt.gz"]
          ++
          # SQLite database files.
          mkYaziUrlEntries usePreloader ["*.db" "*.sqlite" "*.sqlite3"]
          ++
          # Systemd service files.
          mkYaziUrlEntries usePreloader ["*/systemd/*"];

        # keep-sorted end
      };
      # keep-sorted end
    };
  };
}
