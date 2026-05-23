{inputs, ...}: {
  flake-file.inputs.disko = {
    url = "github:nix-community/disko?ref=latest";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  imports = [inputs.disko.flakeModules.disko];

  flake.diskoConfigurations.ext4 = {
    disko.devices = {
      disk = {
        main = {
          type = "disk";
          device = "/dev/nvme0n1";
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
                      # #keep-sorted start
                      "commit=8"
                      "data=writeback"
                      "defaults"
                      "errors=remount-ro"
                      "fast_commit"
                      "journal_async_commit"
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
