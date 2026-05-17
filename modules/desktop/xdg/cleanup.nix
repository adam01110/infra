{
  flake.modules.homeManager.xdgCleanup = {config, ...}: let
    inherit (config.lib.file) mkOutOfStoreSymlink;

    inherit
      (config.xdg)
      # keep-sorted start
      cacheHome
      configHome
      dataHome
      stateHome
      # keep-sorted end
      ;
  in {
    # keep-sorted start block=yes newline_separated=yes
    # Keep renpy saves under xdg data and expose legacy path.
    home.file.".renpy".source = mkOutOfStoreSymlink "${dataHome}/renpy";

    # GET OUT OF MY $HOME!
    home.sessionVariables = {
      # History.
      # keep-sorted start
      HISTFILE = "${stateHome}/bash/history";
      LESSHISTFILE = "${stateHome}/less/history";
      # keep-sorted end

      # Keep ffmpeg config under xdg config home.
      FFMPEG_DATADIR = "${configHome}/ffmpeg";

      # Rust toolchains.
      # keep-sorted start
      CARGO_HOME = "${dataHome}/cargo";
      RUFF_CACHE_DIR = "${cacheHome}/ruff";
      RUSTUP_HOME = "${dataHome}/rustup";
      # keep-sorted end

      # Javascript toolchains.
      # keep-sorted start
      BIOME_CONFIG_PATH = "${configHome}/biome/biome.json";
      BUN_INSTALL = "${dataHome}/bun";
      NODE_REPL_HISTORY = "${dataHome}/node_repl_history";
      # keep-sorted end

      # Java toolschains.
      # keep-sorted start
      GRADLE_USER_HOME = "${dataHome}/gradle";
      MAVEN_ARGS = "--settings ${configHome}/maven/settings.xml";
      MAVEN_OPTS = "-Dmaven.repo.local=${dataHome}/maven/repository";
      # keep-sorted end

      # Gaming.
      # keep-sorted start
      RENPY_MULTIPERSISTENT = "${dataHome}/renpy_shared";
      RENPY_PATH_TO_SAVES = "${dataHome}/renpy";
      WINEPREFIX = "${dataHome}/wineprefixes/default";
      # keep-sorted end
    };
    # keep-sorted end
  };
}
