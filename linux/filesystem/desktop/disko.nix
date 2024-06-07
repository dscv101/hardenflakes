{ config, disks ? [ "/dev/nvme0n1" "/dev/sda1" ], ... }:

{
  disko.devices = {
    disk = {
      nvme0n1 = {
        device = builtins.elemAt disks 0;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1GiB";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "defaults" ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                settings = {
                  allowDiscards = true;
                };
                passwordFile = config.age.secrets.luks.path;
                content = {
                  type = "filesystem";
                  format = "bcachefs";
                  extraArgs = [ "-f" ]; # Override existing partition
                  mountpoint = "/nix";
                  mountOptions = [ "compression=zstd" "noatime" ];
                };
              };
            };
          };
        };
      };

      sda1 = {
        device = builtins.elemAt disks 1;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "hdd";
                settings = {
                  allowDiscards = true;
                  keyFile = "/etc/hdd_luks.key";
                };
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/hdd";
                  mountOptions = [ "noatime" ];
                };
              };
            };
          };
        };
      };
    };

    nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [
          "defaults"
          "size=32G" # 64GB RAM (leaving 32GB for RAM)
          "mode=755"
        ];
      };
    };
  };
}
