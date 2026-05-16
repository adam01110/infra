{self, ...}: {
  flake.modules.homeManager.prism = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    vars,
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
    inherit (vars) defaultLocale;

    # Reuse the XDG downloads path for launcher-managed downloads.
    downloadsDir = config.xdg.userDirs.download;
    monospaceFont = config.stylix.fonts.monospace.name;
  in {
    imports = [
      # keep-sorted start
      self.modules.generic.vars
      self.modules.homeManager.stylixPersonal
      # keep-sorted end
    ];

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
        # Derive language from shared regional defaults.
        # keep-sorted start
        Language = removeSuffix ".UTF-8" defaultLocale;
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
        Consolefont = monospaceFont;
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
