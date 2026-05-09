{
  flake.modules.homeManager.prism = {
    # keep-sorted start
    config,
    lib,
    osConfig,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      attrValues
      getExe
      removeSuffix
      # keep-sorted end
      ;

    # Reuse the XDG downloads path for launcher-managed downloads.
    downloadsDir = config.xdg.userDirs.download;
  in {
    programs.prismlauncher = {
      enable = true;

      package = pkgs.prismlauncher.override {
        # Disable unneeded support.
        # keep-sorted start
        controllerSupport = false;
        gamemodeSupport = false;
        textToSpeechSupport = false;
        # keep-sorted end

        # Specify which Java runtimes to install.
        jdks = attrValues {
          inherit
            (pkgs)
            # keep-sorted start
            jdk17
            jdk21
            jdk8
            temurin-bin-25
            # keep-sorted end
            ;
        };
      };

      settings = {
        # Derive identity and language from host-level configuration.
        # keep-sorted start
        Language = removeSuffix ".UTF-8" osConfig.i18n.defaultLocale;
        LastHostname = osConfig.networking.hostName;
        UseSystemLocale = true;
        # keep-sorted end

        # Follow desktop theming and use the flat white icon pack.
        # keep-sorted start
        ApplicationTheme = "system";
        IconTheme = "flat_white";
        # keep-sorted end

        # Keep status and toolbar controls visible in the main window.
        # keep-sorted start
        StatusBarVisible = true;
        ToolbarsLocked = false;
        # keep-sorted end

        # Set the console font.
        # keep-sorted start
        ConsoleFontSize = 11;
        ConsoleMaxLines = 100000;
        ConsoleOverflowStop = true;
        # keep-sorted end

        # Keep console hidden during normal launches and failures.
        # keep-sorted start
        ShowConsole = false;
        ShowConsoleOnError = false;
        # keep-sorted end

        # Pin Java behavior to managed Nix-provided runtimes.
        # keep-sorted start
        AutomaticJavaDownload = false;
        AutomaticJavaSwitch = false;
        IgnoreJavaCompatibility = true;
        IgnoreJavaWizard = true;
        JavaPath = getExe pkgs.temurin-bin-25;
        UserAskedAboutAutomaticJavaDownload = false;
        # keep-sorted end

        # Set default JVM memory values for instances.
        # keep-sorted start
        MaxMemAlloc = 8192;
        MinMemAlloc = 1024;
        PermGen = 128;
        # keep-sorted end

        # Track downloads in the shared user downloads directory.
        # keep-sorted start
        DownloadsDir = downloadsDir;
        DownloadsDirWatchRecursive = false;
        # keep-sorted end

        # Disable optional runtime overlays and gamemode integration.
        # keep-sorted start
        EnableFeralGamemode = false;
        EnableMangoHud = false;
        # keep-sorted end

        # Keep dependency checks and manual mod movement enabled.
        # keep-sorted start
        ModDependenciesDisabled = false;
        MoveModsFromDownloadsDir = false;
        # keep-sorted end

        # Increase worker counts and retry limits for large packs.
        # keep-sorted start
        NumberOfConcurrentDownloads = 10;
        NumberOfConcurrentTasks = 10;
        NumberOfManualRetries = 10;
        # keep-sorted end

        # Avoid experimental online patch behavior.
        OnlineFixes = false;

        # Close launcher and console after a successful game start.
        # keep-sorted start
        AutoCloseConsole = true;
        CloseAfterLaunch = true;
        # keep-sorted end

        # Keep per-instance and aggregate playtime tracking visible.
        # keep-sorted start
        RecordGameTime = true;
        ShowGameTime = true;
        ShowGameTimeWithoutDays = true;
        ShowGlobalGameTime = true;
        # keep-sorted end

        # Disable optional novelty feature flags.
        TheCat = false;

        # Keep rendering defaults without forcing discrete GPU paths.
        # keep-sorted start
        UseDiscreteGpu = false;
        UseNativeGLFW = true;
        UseNativeOpenAL = true;
        UseZink = false;
        # keep-sorted end
      };
    };
  };
}
