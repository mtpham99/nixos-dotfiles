# default.nix (loki)

{ lib, pkgs, config, ... }:
let
  cfg = config.homelab.containers.loki;

  loki-version = "3.4";

  # volumes
  volume-config = "/srv/loki/config";
  volume-data = "/srv/loki/data";

  # add config files to nix store
  loki-configs-pkg = pkgs.runCommand "homelab-loki-configs" {
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

  options.homelab.containers.loki = {
    enable = lib.mkEnableOption "enable loki container";

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
    system.activationScripts."homelab-loki-volume-setup".text = ''
      mkdir -p ${volume-config}
      if mountpoint -q ${volume-config}/loki-config.yaml; then
        umount ${volume-config}/loki-config.yaml
      fi
      touch ${volume-config}/loki-config.yaml
      mount --bind --options ro ${loki-configs-pkg}/loki-config.yaml ${volume-config}/loki-config.yaml

      mkdir -p ${volume-data}
      chown -R 10001:10001 ${volume-data}
    '';

    virtualisation.oci-containers.containers."${cfg.container-name}" = {
      image = "grafana/loki:${loki-version}";
      volumes = [
        "${volume-config}:/etc/loki"
        "${volume-data}:/loki"
      ];
      extraOptions = [
        "--network=${cfg.network}"
        "--ip=${cfg.ip}"
      ];
      cmd = [
        "-config.file=/etc/loki/loki-config.yaml"
      ];
    };
  };
}
