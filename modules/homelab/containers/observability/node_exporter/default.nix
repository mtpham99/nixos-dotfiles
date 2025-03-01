# default.nix (node_exporter)

{ lib,  config, ... }:
let
  cfg = config.homelab.containers.node_exporter;

  node_exporter-version = "1.9.0";
in
{
  options.homelab.containers.node_exporter = {
    enable = lib.mkEnableOption "enable node_exporter container";

    container-name = lib.mkOption {
      type = lib.types.str;
      description = "container's name";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers."${cfg.container-name}" = {
      image = "quay.io/prometheus/node-exporter:v${node_exporter-version}";
      volumes = [
        "/:/host:ro,rslave"
        "/var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket:ro"
      ];
      extraOptions = [
        "--network=host"
        "--pid=host"
      ];
      cmd = [
        "--path.rootfs=/host"
        "--collector.systemd"
        "--collector.processes"
      ];
    };

    # open port for prometheus
    networking.firewall.allowedTCPPorts = [
      9100
    ];
  };
}
