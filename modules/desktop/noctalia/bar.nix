{
  flake.modules.homeManager.noctalia = {
    # keep-sorted start
    config,
    lib,
    osConfig,
    # keep-sorted end
    ...
  }: let
    inherit (lib) optional;

    cfgBluetooth = osConfig.capabilities.bluetooth;
    cfgGpu = config.programs.noctalia-shell.systemMonitor.enableGpu;
    cfgBattery = config.programs.noctalia-shell.battery.enable;
  in {
    programs.noctalia-shell.settings.bar = {
      # keep-sorted start
      backgroundOpacity = 1;
      density = "compact";
      floating = false;
      outerCorners = false;
      position = "top";
      showCapsule = true;
      useSeparateOpacity = true;
      # keep-sorted end

      widgets = {
        left = [
          {
            id = "SystemMonitor";
            showCpuFreq = true;
            showCpuTemp = true;
            showCpuUsage = true;
            showGpuTemp = cfgGpu;
            showMemoryAsPercent = false;
            showMemoryUsage = true;
            showNetworkStats = false;
            showSwapUsage = true;
          }

          {id = "plugin:privacy-indicator";}

          {
            id = "LockKeys";
            capsLockIcon = "circle-dashed-letter-c";
            numLockIcon = "circle-dashed-letter-n";
            scrollLockIcon = "circle-dashed-letter-s";
            showCapsLock = true;
            showNumLock = false;
            showScrollLock = false;
          }

          {
            id = "ActiveWindow";
            colorizeIcons = false;
            hideMode = "hidden";
            maxWidth = 145;
            scrollingMode = "hover";
            showIcon = true;
            useFixedWidth = false;
          }

          {
            id = "MediaMini";
            hideMode = "hidden";
            hideWhenIdle = false;
            maxWidth = 145;
            scrollingMode = "hover";
            showAlbumArt = true;
            showVisualizer = false;
            useFixedWidth = false;
            visualizerType = "linear";
          }
        ];

        center = [
          {
            id = "Workspace";
            hideUnoccupied = true;
            labelMode = "none";
            followFocusedScreen = true;
          }
        ];

        right = let
          wiremix = config.xdg.desktopEntries.wiremix.exec;
        in
          [
            {
              id = "Tray";
              colorizeIcons = false;
              drawerEnabled = true;
              pinned = [
                "Equibop"
                "Beeper"
                "spotify-client"
                "steam"
              ];
            }

            {
              id = "VPN";
              displayMode = "onhover";
            }

            {id = "NoctaliaPerformance";}

            {
              id = "Volume";
              displayMode = "onhover";
              middleClickCommand = wiremix;
            }

            {
              id = "Microphone";
              displayMode = "onhover";
              middleClickCommand = wiremix;
            }
          ]
          ++ (optional cfgBluetooth {id = "Bluetooth";})
          ++ [
            {id = "Network";}

            {
              id = "Brightness";
              displayMode = "onhover";
            }
          ]
          ++ [{id = "KeepAwake";}]
          # Show the battery widget when enabled.
          ++ (optional cfgBattery {
            id = "Battery";
            showPowerProfiles = true;
            DisplayMode = "icon-hover";
          })
          ++ [
            {id = "plugin:github-feed";}

            {
              id = "NotificationHistory";
              showUnreadBadge = true;
            }

            {
              id = "Clock";
              formatHorizontal = "yyyy-MM-dd HH:mm";
              formatVertical = "HH mm - dd MM";
              tooltipFormat = "ddd, MMM dd HH:mm";
              useCustomFont = false;
              clockColor = "primary";
            }

            {
              id = "ControlCenter";
              colorizeSystemIcon = "tertiary";
              enableColorization = true;
              useDistroLogo = true;
            }
          ];
      };
    };
  };
}
