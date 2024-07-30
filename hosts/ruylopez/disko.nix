# disko.nix

{ ... }:

{
  disko.devices = {
    disk = {
      sda = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            esp = {
              name = "esp";
              type = "EF00";
              size = "512M";
              content = {
                type = "filesystem";
                format = "vfat";
                extraArgs = [ "-n ESP" ];
                mountpoint = "/boot";
                mountOptions = [ "fmask=0077" "dmask=0077" ];
              };
            };

            cr_root = {
              size = "100%";
              content = {
                name = "cr_root";
                type = "luks";
                extraFormatArgs = [ "--label CR_ROOT" ];
                # passwordFile = "";
                # settings.keyFile = "";
                additionalKeyFiles = [ "/tmp/ruylopez-cr_root-keyslot1.bin" ]; # use nixos-anywhere '--disk-encryption-keys' option to upload key
                content = {
                  type = "lvm_pv";
                  vg = "vg_nixos";
                };
              };
            };
          };
        };
      };
    };

    lvm_vg = {
      vg_nixos = {
        type = "lvm_vg";
        lvs = {
          lv_swap = {
            size = "12143860KiB";
            content = {
              type = "swap";
              extraArgs = [ "-L SWAP" ];
            };
          };

          lv_root = {
            size = "100%free";
            content = {
              type = "filesystem";
              format = "xfs";
              extraArgs = [ "-L ROOT" ];
              mountpoint = "/";
              mountOptions = [ "relatime" ];
            };
          };
        };
      };
    };
  };
}
