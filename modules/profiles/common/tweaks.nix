{
  flake.modules.nixos.tweaks = {
    # keep-sorted start
    config,
    lib,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit
      (lib)
      # keep-sorted start
      getExe
      mkEnableOption
      mkIf
      mkOption
      optional
      optionalString
      types
      # keep-sorted end
      ;

    managerSettings = {
      # keep-sorted start
      DefaultTimeoutStartSec = "15s";
      DefaultTimeoutStopSec = "10s";
      # keep-sorted end
    };
  in {
    options.tweaks = {
      # keep-sorted start block=yes newline_separated=yes
      rcuLazy.enable = mkEnableOption "Enable RCU lazy mode.";

      watchdogs.enable = mkOption {
        type = types.bool;
        default = false;
        description = "Keep hardware and NMI watchdogs available for hang detection.";
      };
      # keep-sorted end
    };

    config = {
      # keep-sorted start block=yes newline_separated=yes
      boot = {
        extraModprobeConfig = optionalString (!config.tweaks.watchdogs.enable) ''
          # Disable hardware watchdogs for lower latency.
          blacklist iTCO_wdt
          blacklist wdat_wdt
        '';

        # Enable nt sync for better wine/proton performance.
        kernelModules.ntsync = true;

        kernel.sysctl = {
          # keep-sorted start
          "kernel.nmi_watchdog" = mkIf (!config.tweaks.watchdogs.enable) 0;
          "kernel.printk" = "3 3 3 3";
          "kernel.unprivileged_userns_clone" = 1;
          # keep-sorted end

          # keep-sorted start
          "kernel.kptr_restrict" = 2;
          # keep-sorted end

          # keep-sorted start
          "fs.file-max" = 2097152;
          "net.core.netdev_max_backlog" = 4096;
          "net.ipv4.tcp_mtu_probing" = 1;
          # keep-sorted end
        };

        # Optionally enable rcu lazy mode for battery life on laptops.
        kernelParams = optional config.tweaks.rcuLazy.enable "rcutree.enable_rcu_lazy=1";
      };

      environment.systemPackages = with pkgs; [
        # keep-sorted start
        bash
        coreutils
        hdparm
        smartmontools
        # keep-sorted end
      ];

      security.pam.loginLimits = [
        {
          domain = "@audio";
          item = "nice";
          type = "-";
          value = "-11";
        }
      ];

      systemd = {
        tmpfiles.rules = [
          "e /var/lib/systemd/coredump - - - 3d"
        ];

        user.settings.Manager =
          managerSettings
          // {
            DefaultLimitNOFILE = "1024:1048576";
          };

        settings.Manager =
          managerSettings
          // {
            DefaultLimitNOFILE = "2048:2097152";
          };
      };
      # keep-sorted end

      # Udev rules for power and latency tuning.
      services.udev.extraRules = let
        # keep-sorted start
        hdparm = getExe pkgs.hdparm;
        # keep-sorted end
      in ''
        ${optionalString (!config.services.tlp.enable) ''
          ACTION=="add", SUBSYSTEM=="sound", KERNEL=="card*", DRIVERS=="snd_hda_intel", \
              RUN+="${getExe pkgs.audio-pm-ctl} init"

          ACTION=="add|change", SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_TYPE}=="Mains", ENV{POWER_SUPPLY_ONLINE}=="0", TEST=="/sys/module/snd_hda_intel", \
              RUN+="${getExe pkgs.audio-pm-ctl} battery"

          ACTION=="add|change", SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_TYPE}=="Mains", ENV{POWER_SUPPLY_ONLINE}=="1", TEST=="/sys/module/snd_hda_intel", \
              RUN+="${getExe pkgs.audio-pm-ctl} ac"
        ''}

        ${optionalString (!config.services.tlp.enable) ''
          ACTION=="add", SUBSYSTEM=="usb", ATTR{bInterfaceClass}=="03", \
              ATTRS{removable}=="removable", TEST=="../power/control", \
              ATTR{../power/control}="on"
        ''}

        KERNEL=="rtc0", GROUP="audio"
        KERNEL=="hpet", GROUP="audio"

        ${optionalString (!config.services.tlp.enable) ''
          ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", \
              ATTR{link_power_management_policy}=="*", \
              ATTR{link_power_management_supported}=="1", \
              ATTR{link_power_management_policy}="max_performance"
        ''}

        ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", \
          ATTR{queue/scheduler}="bfq"

        ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", \
          ATTR{queue/scheduler}="adios"

        ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/rotational}=="0", \
          ATTR{queue/scheduler}="adios"

        ${optionalString (!config.services.tlp.enable) ''
          ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", \
            ATTRS{id/bus}=="ata", RUN+="${hdparm} -B 254 -S 0 /dev/%k"
        ''}

        DEVPATH=="/devices/virtual/misc/cpu_dma_latency", OWNER="root", GROUP="audio", MODE="0660"
      '';
    };
  };
}
