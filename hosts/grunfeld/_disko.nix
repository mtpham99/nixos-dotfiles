# disko.nix
# NOTE:
# this system was not originally installed using disko
# hence the existing filesystem is not the EXACT same
# as what is specified by this file (e.g. partition labels, exact sizes, etc.)
# therefore this file currently just serves as a reference point or used to
# install on a new system

{ ... }:

{
  disko.devices = {
    disk = {
      nvme0n1 = {
        type = "disk";
        device = "/dev/nvme0n1";
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
                additionalKeyFiles = [ "/root/luks/grunfeld-cr_root-keyslot1.bin" ];
                content = {
                  type = "lvm_pv";
                  vg = "vg_nixos";
                };
              };
            };
          };
        };
      };

      nvme1n1 = {
        device = "/dev/nvme1n1";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            cr_data0 = {
              size = "100%";
              content = {
                name = "cr_data0";
                type = "luks";
                extraArgs = [ "--label CR_DATA0" ];
                # passwordFile = "";
                # settings.keyFile = "";
                additionalKeyFiles = [ "/root/luks/grunfeld-cr_data0-keyslot1.bin" ];
                content = {
                  type = "lvm_pv";
                  vg = "vg_data";
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
            size = "31743MiB";
            content = {
              type = "swap";
              extraArgs = [ "-L SWAP" ];
            };
          };

          lv_root = {
            size = "100%free";
            content = {
              type = "btrfs";
              extraArgs = [ "-L ROOT" ];
              subvolumes = {
                "@" = {
                  mountpoint = "/";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "@root" = {
                  mountpoint = "/root";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "@persist" = {
                  mountpoint = "/persist";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "@log" = {
                  mountpoint = "/var/log";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "@cache" = {
                  mountpoint = "/var/cache";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "@mpham" = {
                  mountpoint = "/home/mpham";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "/home/mpham/.snapshots" = {};
                "/home/mpham/downloads" = {};
                "/home/mpham/git" = {};
                "/home/mpham/tmp" = {};
                "/home/mpham/.local/share/Steam" = {};
              };
            };
          };
        };
      };

      vg_data = {
        type = "lvm_vg";
        lvs = {
          lv_data = {
            size = "100%free";
            content = {
              type = "filesystem";
              format = "xfs";
              extraArgs = [ "-L DATA" ];
              mountpoint = "/mnt/data";
              mountOptions = [ "nofail" "relatime" ];
            };
          };
        };
      };
    };
  };
}
