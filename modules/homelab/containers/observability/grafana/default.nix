# default.nix (grafana)

{ lib, pkgs, config, ... }:
let
  cfg = config.homelab.containers.grafana;

  # volumes
  volume-config = "/srv/grafana/config";
  volume-data = "/srv/grafana/data";
  volume-provisioning = "/srv/grafana/provisioning";

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
      mkdir -p ${volume-data}
      chown -R 472:472 ${volume-data}

      mkdir -p ${volume-config}
      if mountpoint -q ${volume-config}/grafana.ini; then
        umount ${volume-config}/grafana.ini
      fi
      chown -R 472:472 ${volume-config}
      touch ${volume-config}/grafana.ini
      mount --bind --options ro ${grafana-configs-pkg}/grafana.ini ${volume-config}/grafana.ini

      mkdir -p ${volume-provisioning}/{datasources,dashboards}
      if mountpoint -q ${volume-provisioning}/datasources; then
        umount ${volume-provisioning}/datasources
      fi
      if mountpoint -q ${volume-provisioning}/dashboards; then
        umount ${volume-provisioning}/dashboards
      fi
      chown -R 472:472 ${volume-provisioning}
      mount --bind --options ro ${grafana-configs-pkg}/datasources ${volume-provisioning}/datasources
      mount --bind --options ro ${grafana-configs-pkg}/dashboards ${volume-provisioning}/dashboards

    '';

    virtualisation.oci-containers.containers."${cfg.container-name}" = {
      image = "grafana/grafana-oss:latest";
      volumes = [
        "${volume-config}:/etc/grafana"
        "${volume-data}:/var/lib/grafana"
        "${volume-provisioning}/datasources:/etc/grafana/provisioning/datasources"
        "${volume-provisioning}/dashboards:/etc/grafana/provisioning/dashboards"

        "${config.sops.secrets.grafana-password.path}:${config.sops.secrets.grafana-password.path}:ro"
      ];
      environment = {
        "GF_PATHS_CONFIG" = "/etc/grafana/grafana.ini";
        "GF_PATHS_DATA" = "/var/lib/grafana";
        "GF_PATHS_PROVISIONING" = "/etc/grafana/provisioning";
        "GF_SECURITY_ADMIN_USER" = "admin";
        "GF_SECURITY_ADMIN_PASSWORD__FILE" = config.sops.secrets.grafana-password.path;
      };
      extraOptions = [
        "--network=${cfg.network}"
        "--ip=${cfg.ip}"
      ];
    };
  };
}
