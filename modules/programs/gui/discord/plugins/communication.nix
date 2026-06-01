{
  flake.modules.homeManager.discord = {
    # keep-sorted start
    config,
    vars,
    # keep-sorted end
    ...
  }: {
    programs.nixcord.config.plugins = {
      # keep-sorted start block=yes newline_separated=yes
      ClearURLs.enable = true;

      CopyUserURLs.enable = true;

      autoZipper.enable = true;

      betterCommands.enable = true;

      betterGifAltText.enable = true;

      cleanChannelName.enable = true;

      copyEmojiMarkdown.enable = true;

      copyFileContents.enable = true;

      copyStickerLinks.enable = true;

      copyUserMention.enable = true;

      customTimestamps = {
        enable = true;
      };

      dontRoundMyTimestamps.enable = true;

      expressionCloner.enable = true;

      favoriteGifSearch.enable = true;

      fixCodeblockGap.enable = true;

      fixFileExtensions.enable = true;

      fixImagesQuality.enable = true;

      fixSpotifyEmbeds.enable = true;

      fixYoutubeEmbeds.enable = true;

      forwardAnywhere.enable = true;

      gifPaste.enable = true;

      iLoveSpam.enable = true;

      imageFilename.enable = true;

      messageBurst = {
        enable = true;
        timePeriod = 3;
      };

      messageFetchTimer = {
        enable = true;
        iconColor = config.lib.stylix.colors.base0B;
      };

      messageLatency = {
        enable = true;
        showMillis = true;
        latency = 1;
      };

      messageLinkEmbeds = {
        enable = true;
        messageBackgroundColor = true;
      };

      moreQuickReactions.enable = true;

      noPushToTalk.enable = true;

      normalizeMessageLinks.enable = true;

      polishWording = {
        enable = true;
        # keep-sorted start
        fixCapitalization = true;
        fixPunctuation = true;
        # keep-sorted end
      };

      replyTimestamp.enable = true;

      searchFix.enable = true;

      selfForward.enable = true;

      sendTimestamps.enable = true;

      songLink = {
        enable = true;
        userCountry = vars.countryCode;
      };

      splitLargeMessages.enable = true;

      stickerPaste.enable = true;

      textReplace = {
        enable = true;
        regexRules = [
          # keep-sorted start block=yes newline_separated=yes
          # Minecraft bugs regex.
          {
            find = "(?:^|(?<=[\\s,:;/&]))MC-\\d+(?:(?=[\\s.?!,:;/&])|$) replace: [$&]";
            replace = "(<https://bugs.mojang.com/browse/$&>)";
          }

          # XKCD regex.
          {
            find = "(?:^|(?<=[\s,:;/&]))xkcd\/(\d+)(?:(?=[\s.?!,:;/&])|$)";
            replace = "[$&](https://xkcd.com/$1)";
          }

          # Tenor regex.
          {
            find = "(https:\/\/media1\.tenor\.com\/m\/[^\/]+\/[^\/]+\.gif)(?!\?)";
            replace = "$1?download=1";
          }

          {
            find = "(https:\\/\\/github\\.com\\/[^\\/]+\\/[^\\/]+\\/commit\\/([0-9a-f]{7})([0-9a-f]{0,33}))";
            replace = "[`$2`]($1)";
          }

          {
            find = "(https:\\/\\/github\\.com\\/[^\\/]+\\/[^\\/]+\\/issues\\/([0-9a-f]{1,}))";
            replace = "[`Issue #$2`]($1)";
          }

          {
            find = "(https:\\/\\/github\\.com\\/[^\\/]+\\/[^\\/]+\\/pull\\/([0-9a-f]{1,}))";
            replace = "[`Pull Request #$2`]($1)";
          }

          # Github regex.
          {
            find = "gh:([a-zA-Z0-9_-]+)/([a-zA-Z0-9_.-]+)";
            replace = "[$1/$2](https://github.com/$1/$2)";
          }

          # Reddit regex.
          {
            find = "http(?:s)?:\/\/(?:redd\.it\/|(?:[\w-]+\.)?r[ex]ddit\.com\/)(?:(r\/[\w-]+\/s\/\w+)|(u)(?:ser)?(\/)([\w-]+)(.*?)?|(?:(?:r\/[\w-]+\/)?((c)omments\/))(\w+)(?:\/[^\/\s\)\]\}]+)+(\/)(\w+)|(?:(?:(?:r\/[\w-]+\/)?comments\/)|(?<=redd\.it\/))(\w+)(?:\/.*?)?|(?!r\/|u\/|user\/|comments\/)(.*?)?)\/?(?:[?#][^\s\)\]\}]*)?(?=[\s\)\]\}]|$)";
            replace = "https://rxddit.com/$1$2$3$4$5$6$8$9$7$9$10$11";
          }

          # Steam regex.
          {
            find = "https?://store\.steampowered\.com/app/(\d+)(?:/[^\s]*)?";
            replace = "https://s.team/a/$1";
          }

          {
            find = "tenor\.com\/..-..\/view ";
            replace = "tenor.com/view";
          }
          # keep-sorted end
        ];
      };

      timezones = {
        enable = true;
        _24hTime = true;
      };

      translate.enable = true;

      typingIndicator = {
        enable = true;
        # keep-sorted start
        includeBlockedUsers = true;
        includeIgnoredUsers = true;
        includeMutedChannels = true;
        # keep-sorted end
      };

      unsuppressEmbeds.enable = true;

      userMessagesPronouns.enable = true;

      validReply.enable = true;

      voiceRejoin.enable = true;

      waitForSlot.enable = true;

      webScreenShareFixes.enable = true;

      writeUpperCase = {
        enable = true;
        blockedWords = "http, https";
      };

      # keep-sorted end
    };
  };
}
