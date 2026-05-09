{
  flake.modules.homeManager.discord = _: {
    programs.nixcord.config.plugins = {
      # keep-sorted start block=yes newline_separated=yes
      alwaysTrust.enable = true;

      betterSessions = {
        enable = true;
        backgroundCheck = true;
        checkInterval = 30;
      };

      consoleJanitor = {
        enable = true;

        # keep-sorted start
        disableLoggers = true;
        disableSpotifyLogger = true;
        # keep-sorted end

        allowLevel = {
          # keep-sorted start
          debug = false;
          error = false;
          info = false;
          log = false;
          trace = false;
          warn = false;
          # keep-sorted end
        };
      };

      crashHandler.attemptToNavigateToHome = true;

      declutter.enable = true;

      equibopStreamFixes.enable = true;

      newPluginsManager.enable = true;

      noDevtoolsWarning.enable = true;

      noF1.enable = true;

      noOnboardingDelay.enable = true;

      permissionFreeWill.enable = true;

      startupTimings.enable = true;

      unlimitedAccounts.enable = true;

      validUser.enable = true;
      # keep-sorted end
    };
  };
}
