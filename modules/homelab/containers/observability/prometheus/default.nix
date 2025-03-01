# default.nix (prometheus)

{ lib, pkgs, config, ... }:
let
  cfg = config.homelab.containers.prometheus;

  prometheus-version = "3.2.1";

  # volumes
  volume-config = "/srv/prometheus/config";
  volume-data = "/srv/prometheus/data";

  # add config files to nix store
  prometheus-configs-pkg = pkgs.runCommand "homelab-prometheus-configs" {
    buildInputs = [ pkgs.coreutils ];
    src = ./configs;
  } ''
    cp -r $src/. $out/
  '';
in
{
  imports = [
    ../../docker-network.nix # add route for container ip via bridge
  ];

  options.homelab.containers.prometheus = {
    enable = lib.mkEnableOption "enable prometheus container";

    container-name = lib.mkOption {
      type = lib.types.str;
      description = "container's name";
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
    system.activationScripts."homelab-prometheus-volume-setup".text = ''
      # make sure volume path exists
      mkdir -p ${volume-data}
      chown -R nobody:nogroup ${volume-data}

      mkdir -p ${volume-config}
      if mountpoint -q ${volume-config}/prometheus.yml; then
        umount ${volume-config}/prometheus.yml
      fi
      touch ${volume-config}/prometheus.yml
      mount --bind --options ro ${prometheus-configs-pkg}/prometheus.yml ${volume-config}/prometheus.yml
    '';

    virtualisation.oci-containers.containers."${cfg.container-name}" = {
      image = "prom/prometheus:v${prometheus-version}";
      volumes = [
        "${volume-config}:/etc/prometheus"
        "${volume-data}:/prometheus"
      ];
      extraOptions = [
        "--network=${cfg.network}"
        "--ip=${cfg.ip}"
      ];
    };
  };
}
