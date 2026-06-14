{
  flake.diskoConfigurations.ext4 = disk: {
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

              nixos = {
                size = "100%";
                content = {
                  type = "luks";
                  name = "crypted";
                  settings.allowDiscards = true;
                  content = {
                    type = "filesystem";
                    format = "ext4";
                    mountpoint = "/";
                    mountOptions = [
                      # keep-sorted start
                      "defaults"
                      "errors=remount-ro"
                      "noatime"
                      # keep-sorted end
                    ];
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
