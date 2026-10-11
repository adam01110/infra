{
  flake.modules.homeManager.discord = {config, ...}: let
    cfgCamera = config.programs.nixcord.equibop.camera.enable;
  in {
    programs.nixcord.config.plugins = {
      # keep-sorted start block=yes newline_separated=yes
      betterImageEditor.enable = true;

      biggerStreamPreview.enable = true;

      callTimer = {
        enable = true;
        allCallTimers = true;
      };

      disableCallIdle.enable = true;

      disableCameras.enable = !cfgCamera;

      limitlessScreenshare.enable = true;

      mediaPlaybackSpeed.enable = true;

      musicControls = {
        enable = true;
        # keep-sorted start
        showSpotifyControls = true;
        useSpotifyUris = true;
        # keep-sorted end
        lyricsConversion = "Romanized";
      };

      pictureInPicture.enable = true;

      vcPanelSettings = {
        enable = true;
        camera = cfgCamera;

        # keep-sorted start
        showInputDeviceHeader = true;
        showOutputDeviceHeader = true;
        showVideoDeviceHeader = true;
        # keep-sorted end
      };

      voiceButtons = {
        enable = true;
        whichNameToShow = "username";
      };

      voiceChatDoubleClick.enable = true;

      voiceDownload.enable = true;

      voiceMessages.enable = true;

      voiceMessagesInBackground.enable = true;

      volumeBooster.enable = true;
      # keep-sorted end
    };
  };
}
