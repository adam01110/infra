{self, ...}: {
  flake.modules.nixos.laptop = {pkgs, ...}: {
    imports = with self.modules.nixos; [
      # Hardware
      # keep-sorted start
      bluetooth
      lidswitch
      roccat
      # keep-sorted end

      # Profiles
      # keep-sorted start
      gaming
      personal
      # keep-sorted end

      # Services
      # keep-sorted start
      scx-loader
      tlp
      wifi
      # keep-sorted end
    ];

    # System version for state compatibility - do not modify.
    system.stateVersion = "26.05";

    networking.hostName = "laptop";

    # Primary nvme disk for disko partitioning.
    disko.selectedDisk = "/dev/nvme0n1";

    services.timezone = "automatic-timezoned";

    tweaks.rcuLazy.enable = true;

    # Use x86-64-v4 CachyOS LTO kernel.
    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v4;

    powerManagement.powertop.enable = true;

    # Advanced power management for laptop battery optimization.
    services = {
      thermald.enable = true;

      tlp.settings = {
        # Cpu performance profiles: maximize performance on ac, conserve battery on bat.
        # keep-sorted start
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        # keep-sorted end

        # Cpu frequency limits: allow full range on ac, cap at 30% on battery.
        # keep-sorted start
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MAX_PERF_ON_BAT = 30;
        CPU_MIN_PERF_ON_AC = 0;
        CPU_MIN_PERF_ON_BAT = 0;
        # keep-sorted end

        # Disable cpu boost because it makes noise FOR SOME REASON ?!.
        CPU_BOOST_ON_AC = 0;

        # Platform power profiles: balanced on ac, low power on battery.
        # keep-sorted start
        PLATFORM_PROFILE_ON_AC = "balanced";
        PLATFORM_PROFILE_ON_BAT = "low-power";
        # keep-sorted end

        # Sleep modes.
        # keep-sorted start
        MEM_SLEEP_ON_AC = "s2idle";
        MEM_SLEEP_ON_BAT = "s2idle";
        # keep-sorted end

        DISK_DEVICES = "nvme-Samsung_SSD_980_PRO_500GB_S5GYNX0W331360B";

        # Intel gpu frequency limits: high performance on ac, reduced on battery.
        # keep-sorted start
        INTEL_GPU_BOOST_FREQ_ON_AC = 1300;
        INTEL_GPU_BOOST_FREQ_ON_BAT = 700;
        INTEL_GPU_MAX_FREQ_ON_AC = 1300;
        INTEL_GPU_MAX_FREQ_ON_BAT = 450;
        INTEL_GPU_MIN_FREQ_ON_AC = 100;
        INTEL_GPU_MIN_FREQ_ON_BAT = 100;
        # keep-sorted end

        # Disable unused amd gpu features since this is intel graphics.
        # keep-sorted start
        AMDGPU_ABM_LEVEL_ON_AC = "";
        AMDGPU_ABM_LEVEL_ON_BAT = "";
        PCIE_ASPM_ON_AC = "";
        RADEON_DPM_PERF_LEVEL_ON_AC = "";
        RADEON_DPM_PERF_LEVEL_ON_BAT = "";
        # keep-sorted end
      };
    };
  };
}
