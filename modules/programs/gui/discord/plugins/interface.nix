{self, ...}: {
  flake.modules.homeManager.discord = {
    # keep-sorted start
    config,
    lib,
    # keep-sorted end
    ...
  }: let
    inherit (lib) fromHexString mkEnableOption;
  in
    # Interface and layout related plugins.
    {
      imports = [self.modules.homeManager.stylixPersonal];

      # User option to toggle camera features in plugins.
      options.programs.nixcord.equibop.camera.enable = mkEnableOption "Enable camera functionality for Equibop plugins.";

      config.programs.nixcord.config.plugins = {
        # keep-sorted start block=yes newline_separated=yes
        FullVCPFP.enable = true;

        USRBG = {
          enable = true;
          voiceBackground = true;
        };

        UserPFP.enable = true;

        accountPanelServerProfile = {
          enable = true;
          prioritizeServerProfile = true;
        };

        betterActivities = {
          enable = true;
          # keep-sorted start
          memberList = false;
          removeGameActivityStatus = true;
          renderGifs = false;
          # keep-sorted end
        };

        betterSettings = {
          enable = true;
          disableFade = false;
        };

        betterUploadButton.enable = true;

        cleanerChannelGroups.enable = true;

        clickableRoles.enable = true;

        customIdle = {
          enable = true;
          remainInIdle = false;
          idleTimeout = 5.0;
        };

        dearrow = {
          enable = true;
          replaceElements = 1;
        };

        decor.enable = true;

        fakeNitro = {
          enable = true;
          transformCompoundSentence = true;
        };

        fakeProfileThemes.enable = true;

        fullSearchContext.enable = true;

        fullUserInChatbox.enable = true;

        gameActivityToggle.enable = true;

        globalBadges.enable = true;

        greetStickerPicker.enable = true;

        mentionAvatars.enable = true;

        micLoopbackTester.enable = true;

        neverPausePreviews.enable = true;

        noNitroUpsell.enable = true;

        noPendingCount = {
          enable = true;
          # keep-sorted start
          hideFriendRequestsCount = false;
          hideMessageRequestsCount = false;
          # keep-sorted end
        };

        noUnblockToJump.enable = true;

        platformIndicators.enable = true;

        platformSpoofer.enable = true;

        previewMessage.enable = true;

        questify = {
          enable = true;
          # keep-sorted start
          completeGameQuestsInBackground = true;
          completeVideoQuestsInBackground = true;
          # keep-sorted end
          fetchingQuestsInterval = 0;
          # keep-sorted start
          questButtonDisplay = "never";
          questButtonUnclaimed = "none";
          # keep-sorted end
          # keep-sorted start
          restyleQuestsClaimed = fromHexString config.lib.stylix.colors.base0E;
          restyleQuestsExpired = fromHexString config.lib.stylix.colors.base00;
          restyleQuestsIgnored = fromHexString config.lib.stylix.colors.base08;
          restyleQuestsUnclaimed = fromHexString config.lib.stylix.colors.base0D;
          # keep-sorted end
        };

        readAllNotificationsButton.enable = true;

        roleColorEverywhere.enable = true;

        serverListIndicators = {
          enable = true;
          mode = 3;
        };

        showAllMessageButtons.enable = true;

        showBadgesInChat.enable = true;

        showHiddenThings = {
          enable = true;
        };

        statusWhileActive.enable = true;

        themeAttributes.enable = true;

        title = {
          enable = true;
          title = "Equibop";
        };

        unlockedAvatarZoom.enable = true;

        userVoiceShow.enable = true;

        viewIcons.enable = true;
        # keep-sorted end
      };
    };
}
