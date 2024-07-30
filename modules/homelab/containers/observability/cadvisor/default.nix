# default.nix (cadvisor)

{ lib, pkgs, config, ... }:
let
  cfg = config.homelab.containers.cadvisor;
in
{
  imports = [
    ../../../../nixos/docker.nix # check podman or docker
    ../../docker-network.nix # add route for container ip via bridge
  ];

  options.homelab.containers.cadvisor = {
    enable = lib.mkEnableOption "enable cadvisor container";

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

    virtualisation.oci-containers.containers."${cfg.container-name}" = {
      image = "gcr.io/cadvisor/cadvisor:latest";
      volumes = [
        "/:/rootfs:ro"
        "/var/run:/var/run:ro"
        "/sys:/sys:ro"
        (
          if config.docker.use-podman then
            "/var/lib/containers:/var/lib/containers:ro"
          else
            "/var/lib/docker:/var/lib/docker:ro"
        )
        "/dev/disk:/dev/disk:ro"
      ];
      extraOptions = [
        "--network=${cfg.network}"
        "--ip=${cfg.ip}"
        "--device=/dev/kmsg"
        "--privileged"
      ];
    };
  };
}
