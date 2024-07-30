# default.nix (grafana)

{ lib, pkgs, config, ... }:
let
  cfg = config.homelab.containers.grafana;

  # volumes
  volume-config = "/srv/grafana/config";
  volume-data = "/srv/grafana/data";

  # add config files to nix store
  grafana-configs-pkg = pkgs.runCommand "homelab-grafana-configs" {
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

  options.homelab.containers.grafana = {
    enable = lib.mkEnableOption "enable grafana container";

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
    system.activationScripts."homelab-grafana-volume-setup".text = ''
      # make sure volume path exists
      mkdir -p ${volume-config}
      mkdir -p ${volume-data}

      # bind mount (read only) config file
      if mountpoint -q ${volume-config}/grafana.ini; then
        umount ${volume-config}/grafana.ini
      fi

      chown -R 472:472 ${volume-config}
      chown -R 472:472 ${volume-data}

      touch ${volume-config}/grafana.ini
      mount --bind --options ro ${grafana-configs-pkg}/grafana.ini ${volume-config}/grafana.ini
    '';

    virtualisation.oci-containers.containers."${cfg.container-name}" = {
      image = "grafana/grafana-oss:latest";
      volumes = [
        # "${volume-config}:/etc/grafana"
        "${volume-data}:/var/lib/grafana"
      ];
      extraOptions = [
        "--network=${cfg.network}"
        "--ip=${cfg.ip}"
      ];
    };
  };
}
