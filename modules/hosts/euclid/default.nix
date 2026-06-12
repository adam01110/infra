{self, ...}: {
  flake.modules.nixos.euclid = {...}: {
    imports = with self.modules.nixos; [
      # Profiles
      server

      # Services
      # keep-sorted start
      authentik
      cloudbeaver
      crowdsec-server
      dockhand
      godns
      gotify-server
      mysql
      postgres
      traefik
      wireguard
      # keep-sorted end
    ];

    # System version for state compatibility - do not modify.
    system.stateVersion = "26.05";

    networking.hostName = "euclid";

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
        journalctl_filter = ["_SYSTEMD_UNIT=sshd.service"];
        labels.type = "syslog";
        source = "journalctl";
      }
      # keep-sorted end
    ];

    # Wireguard stuff.
    services.homelabWireguard = {
      enable = true;
      address = "10.100.0.1/24";
      privateKeySecret = "wireguard/euclid/private_key";
    };
    networking.hosts = {
      "10.100.0.1" = ["euclid.wg"];
    };
    networking.firewall.interfaces.wg0.allowedTCPPorts = [
      # keep-sorted start numeric=yes
      3000
      3306
      5432
      # keep-sorted end
    ];

    # Primary nvme disk for disko partitioning.
    disko.selectedDisk = "/dev/nvme0n1";

    # extra data mounts.
    fileSystems = let
      # helper for btrfs mounts with shared options.
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
      "/mnt/immich" = mkBtrfsMount "/dev/disk/by-uuid/2262a52f-3110-462e-815a-7717886b8cc7" "root";
      "/mnt/media" = mkBtrfsMount "/dev/disk/by-uuid/7bf5484e-67c1-4c67-a20f-cd47b1d6fb21" "root";
      # keep-sorted end
    };
  };
}
