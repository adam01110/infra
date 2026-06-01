{
  flake.modules.homeManager.noctalia = {config, ...}: {
    programs.noctalia-shell.settings.general = let
      # Use sharp corners (no rounding) for consistent design.
      radius = 0;

      cfgTouch = config.programs.hylix.touch.enable or false;
    in {
      # keep-sorted start
      animationSpeed = 2;
      dimmerOpacity = 0;
      iRadiusRatio = radius;
      lockOnSuspend = true;
      radiusRatio = radius;
      reverseScroll = cfgTouch;
      scaleRatio = 0.8;
      shadowDirection = "center";
      shadowOffsetX = 0;
      shadowOffsetY = 0;
      showChangelogOnStartup = false;
      telemetryEnabled = false;
      # keep-sorted end

      # keep-sorted start
      clockStyle = "analog";
      lockScreenAnimations = true;
      lockScreenBlur = 0.2;
      # keep-sorted end

      keybinds = {
        # keep-sorted start block=yes newline_separated=yes
        keyDown = [
          # keep-sorted start
          "Ctrl+J"
          "Down"
          # keep-sorted end
        ];

        keyLeft = [
          # keep-sorted start
          "Ctrl+H"
          "Left"
          # keep-sorted end
        ];

        keyRight = [
          # keep-sorted start
          "Ctrl+L"
          "Right"
          # keep-sorted end
        ];

        keyUp = [
          # keep-sorted start
          "Ctrl+K"
          "Up"
          # keep-sorted end
        ];
        # keep-sorted end
      };
    };
  };
}
