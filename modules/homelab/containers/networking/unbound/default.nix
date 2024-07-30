# default.nix (unbound)

{ lib, pkgs, config, ... }:
let
  cfg = config.homelab.containers.unbound;

  # unbound-redis-metrics docker image file
  unbound-redis-metrics-tag = "unbound1.20.0-redis7.4.0";
  unbound-redis-metrics-img = builtins.fetchurl {
    url = "https://github.com/mtpham99/unbound-redis-metrics/releases/download/v0.1.0/${unbound-redis-metrics-tag}.tar.gz";
    sha256 = "1jpf00ljw7ccfp004xc97lyd8li53vvsqs81g2lrxyn9k51398ik";
  };

  # volumes
  volume-configs = "/srv/unbound-redis/configs";
  volume-logs = "/srv/unbound-redis/logs";

  # add config files to nix store
  unbound-redis-configs-pkg = pkgs.runCommand "homelab-unbound-redis-configs" {
    buildInputs = [ pkgs.coreutils ];
    src = ./configs;
  } ''
    cp -r $src/. $out/
  '';
in
{
  imports = [
    ../../../../nixos/docker.nix # expose docker executable
    ../../docker-network.nix # add route for container ip via bridge
  ];

  options.homelab.containers.unbound = {
    enable = lib.mkEnableOption "enable unbound container";

    container-name = lib.mkOption {
      type = lib.types.str;
      description = "container's name";
    };

    custom-config = lib.mkOption {
      type = lib.types.str;
      description = "custom config file written to ${volume-configs}/unbound-custom.conf and mounted at /etc/unbound.d/custom.conf inside container";
      default = "";
    };
    loki-address = lib.mkOption {
      type = lib.types.str;
      description = "address of loki server for promtail to use";
    };

    network = lib.mkOption {
      type = lib.types.str;
      description = "container's network";
    };
    ip = lib.mkOption {
      type = lib.types.str;
      description = "container's ip address";
    };
    add-to-bridge = lib.mkOption {
      type = lib.types.bool;
      description = "allow host to communicate with this container";
      default = config.homelab.containers.docker-network.enable-bridge;
    };
  };

  config = lib.mkIf cfg.enable {
    # add route for container ip via bridge
    homelab.containers.docker-network.bridge-routes = lib.mkIf (cfg.add-to-bridge && config.homelab.containers.docker-network.enable-bridge) [ cfg.ip ];

    # setup container's volume
    system.activationScripts."homelab-unbound-volume-setup".text = ''
      # make sure volume path exists
      mkdir -p ${volume-configs}
      mkdir -p ${volume-logs}

      # bind mount (read only) configs
      if mountpoint -q ${volume-configs}/unbound.conf; then
        umount ${volume-configs}/unbound.conf
      fi
      touch ${volume-configs}/unbound.conf
      mount --bind --options ro ${unbound-redis-configs-pkg}/unbound.conf ${volume-configs}/unbound.conf
      if mountpoint -q ${volume-configs}/redis.conf; then
        umount ${volume-configs}/redis.conf
      fi
      touch ${volume-configs}/redis.conf
      mount --bind --options ro ${unbound-redis-configs-pkg}/redis.conf ${volume-configs}/redis.conf

      # write custom config file
      # make sure it is included in ${unbound-redis-configs-pkg}/unbound.conf
      echo -n '${cfg.custom-config}' > ${volume-configs}/unbound-custom.conf
    '';

    virtualisation.oci-containers.containers."${cfg.container-name}" = {
      imageFile = unbound-redis-metrics-img;
      image = "unbound-redis-metrics:${unbound-redis-metrics-tag}";
      environment = {
        LOKI_ADDRESS = cfg.loki-address;
      };
      volumes = [
        "${volume-logs}:/var/log"
        "${volume-configs}/unbound.conf:/etc/unbound.conf"
        "${volume-configs}/redis.conf:/etc/redis.conf"
        "${volume-configs}/unbound-custom.conf:/etc/unbound.d/custom.conf"
      ];
      extraOptions = [
        "--network=${cfg.network}"
        "--ip=${cfg.ip}"
      ];
    };
  };
}
