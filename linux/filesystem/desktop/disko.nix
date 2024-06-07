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
};
}


2600:1700:6841:40e0:3941:3f83:5596:150d
