{
  flake.diskoConfigurations.btrfs = disk: {
    disko.devices = {
      disk = {
        main = {
          type = "disk";
          device = disk;
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = "256M";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = ["umask=0077"];
                };
              };

              luks = {
                size = "100%";
                content = {
                  type = "luks";
                  name = "crypted";
                  settings.allowDiscards = true;
                  content = {
                    type = "btrfs";
                    extraArgs = ["-f"];
                    subvolumes = let
                      mountOptions = [
                        # keep-sorted start
                        "compress=zstd:1"
                        "defaults"
                        "noatime"
                        # keep-sorted end
                      ];
                    in {
                      root = {
                        mountpoint = "/";
                        inherit mountOptions;
                      };
                      home = {
                        mountpoint = "/home";
                        inherit mountOptions;
                      };
                      rootHome = {
                        mountpoint = "/root";
                        inherit mountOptions;
                      };
                      lib = {
                        mountpoint = "/var/lib";
                        inherit mountOptions;
                      };
                      cache = {
                        mountpoint = "/var/cache";
                        inherit mountOptions;
                      };
                      log = {
                        mountpoint = "/var/log";
                        inherit mountOptions;
                      };
                      nix = {
                        mountpoint = "/nix";
                        inherit mountOptions;
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
