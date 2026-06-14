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
      plugins.faster-piper = pkgs.nur.repos.adam0.yaziPlugins.faster-piper;

      settings.plugin = {
        # keep-sorted start newline_separated=yes
        prepend_preloaders =
          mkYaziUrlEntries "${piper} CLICOLOR_FORCE=1 glow -w=$w -s=dark -- \"$1\"" ["*.md"]
          ++
          # SQLite database files.
          mkYaziUrlEntries ''${piper} sqlite3 -readonly "$1" ".schema --indent"'' ["*.{db,sqlite,sqlite3}"]
          ++
          # Systemd service files.
          mkYaziUrlEntries ''${piper} ${systemdStatusPreview} --from-path "$1"'' ["*/systemd/*"];

        # Previewers routed through faster-piper.
        prepend_previewers =
          mkYaziUrlEntries usePreloader ["*.md"]
          ++
          # SQLite database files.
          mkYaziUrlEntries usePreloader ["*.{db,sqlite,sqlite3}"]
          ++
          # Systemd service files.
          mkYaziUrlEntries usePreloader ["*/systemd/*"];

        # keep-sorted end
      };
    };
  };
}
