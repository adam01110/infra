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
      getExe'
      mkEnableOption
      optional
      # keep-sorted end
      ;
  in {
    options.tweaks.rcuLazy.enable = mkEnableOption "Enable RCU lazy mode.";

    config = {
      # keep-sorted start block=yes newline_separated=yes
      # Kernel parameters aimed at low latency desktops.
      boot = {
        # Audio power management: disable power saving for continuous audio availability.
        extraModprobeConfig = ''
          options snd_hda_intel power_save=0

          # Disable hardware watchdogs for lower latency.
          blacklist iTCO_wdt
          blacklist wdat_wdt
        '';

        # Enable nt sync for better wine/proton performance.
        kernelModules.ntsync = true;

        # Memory and system tuning for desktop responsiveness.
        kernel.sysctl = {
          # keep-sorted start
          "vm.swappiness" = 100;
          "vm.vfs_cache_pressure" = 50;
          # keep-sorted end

          # keep-sorted start
          "vm.dirty_background_bytes" = 67108864;
          "vm.dirty_bytes" = 268435456;
          "vm.dirty_writeback_centisecs" = 1500;
          "vm.page-cluster" = 0;
          # keep-sorted end

          # keep-sorted start
          "kernel.nmi_watchdog" = 0;
          "kernel.printk" = "3 3 3 3";
          "kernel.unprivileged_userns_clone" = 1;
          # keep-sorted end

          # keep-sorted start
          "kernel.kexec_load_disabled" = 1;
          "kernel.kptr_restrict" = 2;
          # keep-sorted end

          # keep-sorted start
          "fs.file-max" = 2097152;
          "net.core.netdev_max_backlog" = 4096;
          "net.ipv4.ip_forward" = 1;
          "net.ipv4.tcp_mtu_probing" = 1;
          "net.ipv4.tcp_tw_reuse" = 1;
          # keep-sorted end

          # Remove the global rt throttle so audio workloads can hold cpu time when needed.
          "kernel.sched_rt_runtime_us" = -1;
        };

        # Kernel boot parameters for additional tuning.
        kernelParams =
          [
            # Enable lru page generation for better memory management.
            "lru_gen=y"
          ]
          # Optionally enable rcu lazy mode for battery life on laptops.
          ++ optional config.tweaks.rcuLazy.enable "rcutree.enable_rcu_lazy=1";
      };

      # Assorted low-level tweaks and helper tools.
      environment.systemPackages = with pkgs; [
        # keep-sorted start
        bash
        coreutils
        hdparm
        # keep-sorted end
      ];

      # Systemd limits and tmpfiles overrides.
      systemd = {
        coredump.settings.Coredump.Storage = "journal";

        tmpfiles.rules = [
          "e /var/lib/systemd/coredump - - - 3d"

          "w! /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none - - - - 409"
          "w! /sys/kernel/mm/transparent_hugepage/defrag - - - - defer+madvise"
        ];

        user.settings.Manager.DefaultLimitNOFILE = "1024:1048576";

        settings.Manager = {
          # keep-sorted start
          DefaultLimitNOFILE = "2048:2097152";
          DefaultTimeoutStartSec = "15s";
          DefaultTimeoutStopSec = "10s";
          # keep-sorted end
        };
      };
      # keep-sorted end

      # Udev rules for audio power saving and disk scheduler tuning.
      services.udev.extraRules = let
        # keep-sorted start
        bash = getExe pkgs.bash;
        hdparm = getExe pkgs.hdparm;
        # keep-sorted end

        # keep-sorted start
        cat = getExe' pkgs.coreutils "cat";
        echo = getExe' pkgs.coreutils "echo";
        touch = getExe' pkgs.coreutils "touch";
        # keep-sorted end
      in ''
        ACTION=="add", SUBSYSTEM=="sound", KERNEL=="card*", DRIVERS=="snd_hda_intel", TEST!="/run/udev/snd-hda-intel-powersave", \
            RUN+="${bash} -c '${touch} /run/udev/snd-hda-intel-powersave; \
                [[ $$((${cat} /sys/class/power_supply/BAT0/status 2>/dev/null) != \"Discharging\" ]] && \
                ${echo} $$((${cat} /sys/module/snd_hda_intel/parameters/power_save) > /run/udev/snd-hda-intel-powersave && \
                ${echo} 0 > /sys/module/snd_hda_intel/parameters/power_save'"

        SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="0", TEST=="/sys/module/snd_hda_intel", \
            RUN+="${bash} -c '${echo} $$((${cat} /run/udev/snd-hda-intel-powersave 2>/dev/null || \
                ${echo} 10) > /sys/module/snd_hda_intel/parameters/power_save'"

        SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="1", TEST=="/sys/module/snd_hda_intel", \
            RUN+="${bash} -c '[[ $$((${cat} /sys/module/snd_hda_intel/parameters/power_save) != 0 ]] && \
                ${echo} $$(${cat} /sys/module/snd_hda_intel/parameters/power_save) > /run/udev/snd-hda-intel-powersave; \
                ${echo} 0 > /sys/module/snd_hda_intel/parameters/power_save'"

        ACTION=="change", KERNEL=="zram0", ATTR{initstate}=="1", SYSCTL{vm.swappiness}="150", \
          RUN+="${bash} -c '${echo} N > /sys/module/zswap/parameters/enabled'"

        KERNEL=="rtc0", GROUP="audio"
        KERNEL=="hpet", GROUP="audio"

        ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", \
            ATTR{link_power_management_policy}=="*", \
            ATTR{link_power_management_supported}=="1", \
            ATTR{link_power_management_policy}="max_performance"

        ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", \
          ATTR{queue/scheduler}="bfq"

        ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", \
          ATTR{queue/scheduler}="adios"

        ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/rotational}=="0", \
          ATTR{queue/scheduler}="adios"

        ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", \
          ATTRS{id/bus}=="ata", RUN+="${hdparm} -B 254 -S 0 /dev/%k"

        DEVPATH=="/devices/virtual/misc/cpu_dma_latency", OWNER="root", GROUP="audio", MODE="0660"
      '';
    };
  };
}
