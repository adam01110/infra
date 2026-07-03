{self, ...}: {
  flake.modules.nixos.euclid = {
    # keep-sorted start
    config,
    pkgs,
    # keep-sorted end
    ...
  }: {
    imports = with self.modules.nixos; [
      # Profiles
      server

      # Services
      # keep-sorted start
      apprise
      authentik
      cloudbeaver
      crowdsec-server
      dockhand
      flaresolverr
      godns
      gotify-server
      mysql
      postgres
      protonWireguard
      traefik
      wireguard
      # keep-sorted end
    ];

    # System version for state compatibility - do not modify.
    system.stateVersion = "26.05";

    networking.hostName = "euclid";

    # Use x86-64-v3 CachyOS LTO kernel.
    boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3;

    # Disable UAS for the Samsung T7 to avoid USB transport aborts.
    boot.kernelParams = ["usb-storage.quirks=04e8:4001:u"];

    # Same-host connection: hawser reaches dockhand directly without public TLS.
    services.hawser.dockhandServerUrl = "ws://127.0.0.1:3000/api/hawser/connect";

    services.crowdsec.settings.acquisitions = [
      # keep-sorted start block=yes newline_separated=yes
      {
        appsec_configs = ["crowdsecurity/appsec-default"];
        labels.type = "appsec";
        listen_addr = "127.0.0.1:7424";
        source = "appsec";
      }

      {
        container_name = ["jellyfin"];
        docker_host = "unix:///run/podman/podman.sock";
        labels.type = "jellyfin";
        source = "docker";
      }

      {
        container_name = ["seerr"];
        docker_host = "unix:///run/podman/podman.sock";
        labels.type = "jellyseerr";
        source = "docker";
      }

      {
        filenames = ["/var/log/traefik/*.log"];
        labels.type = "traefik";
        source = "file";
      }

      {
        journalctl_filter = [
          "_SYSTEMD_UNIT=authentik.service"
          "_SYSTEMD_UNIT=authentik-worker.service"
        ];
        labels.type = "authentik";
        source = "journalctl";
      }

      {
        journalctl_filter = ["_SYSTEMD_UNIT=gotify-server.service"];
        labels.type = "gotify";
        source = "journalctl";
      }

      {
        journalctl_filter = ["_SYSTEMD_UNIT=sshd.service"];
        labels.type = "syslog";
        source = "journalctl";
      }
      # keep-sorted end
    ];

    services.homelabWireguard = {
      enable = true;
      address = "10.100.0.1/24";
      privateKeySecret = "wireguard/euclid/private_key";
    };
    networking.hosts = {
      "10.100.0.1" = ["euclid.wg"];
    };

    users.users.${config.services.crowdsec.user}.extraGroups = ["podman" "traefik"];

    systemd.services.crowdsec = {
      after = ["podman.socket"];
      wants = ["podman.socket"];
    };

    # Public Git SSH port for the Tangled knot container.
    networking.firewall.allowedTCPPorts = [2223];
    networking.firewall.allowedUDPPorts = [7359];

    # Primary nvme disk for disko partitioning.
    disko.selectedDisk = "/dev/nvme0n1";

    # extra data mounts.
    fileSystems = let
      # Btrfs mounts with shared options.
      mkBtrfsMount = device: subvol: {
        inherit device;
        fsType = "btrfs";
        options = [
          # keep-sorted start
          "compress=zstd"
          "defaults"
          "noatime"
          "subvol=${subvol}"
          # keep-sorted end
        ];
      };
    in {
      # keep-sorted start
      "/mnt/copyparty" = mkBtrfsMount "/dev/disk/by-uuid/2262a52f-3110-462e-815a-7717886b8cc7" "copyparty";
      "/mnt/immich" = mkBtrfsMount "/dev/disk/by-uuid/2262a52f-3110-462e-815a-7717886b8cc7" "immich";
      "/mnt/media" = mkBtrfsMount "/dev/disk/by-uuid/7bf5484e-67c1-4c67-a20f-cd47b1d6fb21" "root";
      # keep-sorted end
    };
  };
}
