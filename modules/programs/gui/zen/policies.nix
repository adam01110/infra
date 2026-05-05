{
  flake.modules.homeManager.zen = {
    programs.zen-browser.policies = {
      # keep-sorted start
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxScreenshots = true;
      DisableFirefoxStudies = true;
      DisableForgetButton = true;
      DisableFormHistory = true;
      DisableMasterPasswordCreation = true;
      DisablePasswordReveal = true;
      DisablePocket = true;
      DisableSafeMode = true;
      DisableSetDesktopBackground = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      HttpsOnlyMode = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
      PDFjs.Enabled = false;
      PasswordManagerEnabled = false;
      SearchSuggestEnabled = false;
      SkipTermsOfUse = true;
      StartDownloadsInTempDirectory = true;
      TranslateEnabled = false;
      # keep-sorted end

      # keep-sorted start block=yes newline_separated=yes
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };

      GenerativeAI = {
        Enabled = false;
        Chatbot = false;
        LinkPreviews = false;
        TabGroups = false;
        Locked = true;
      };
      # keep-sorted end
    };
  };
}
