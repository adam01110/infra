{
  flake.modules.homeManager.discord = {
    programs.nixcord.config.plugins = {
      # keep-sorted start block=yes newline_separated=yes
      betterBlockedUsers.enable = true;

      betterInvites.enable = true;

      forceOwnerCrown.enable = true;

      friendshipRanks.enable = true;

      implicitRelationships.enable = true;

      inviteDefaults.enable = true;

      memberCount.enable = true;

      moreUserTags.enable = true;

      mutualGroupDms.enable = true;

      newGuildSettings = {
        enable = true;
        messages = 1;
      };

      pauseInvitesForever.enable = true;

      relationshipNotifier.enable = true;

      reviewDb = {
        enable = true;
        hideBlockedUsers = false;
      };

      serverInfo.enable = true;

      showConnections = {
        enable = true;
        iconSpacing = 0;
      };

      showHiddenChannels.enable = true;

      showTimeoutDuration.enable = true;

      songSpotlight.enable = true;

      sortFriends = {
        enable = true;
        showDates = true;
      };

      whoReacted.enable = true;
      # keep-sorted end
    };
  };
}
