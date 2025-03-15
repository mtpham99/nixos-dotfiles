# default.nix (komga)

{ lib, pkgs, config, ... }:
let
  cfg = config.homelab.containers.komga;

  komga-version = "1.21.2";

  # volumes
  volume-config = "/srv/komga/config";
  volume-data = "/srv/komga/data";
in
{
  imports = [
    ../../docker-network.nix # add route for container ip via bridge
  ];

  options.homelab.containers.komga = {
    enable = lib.mkEnableOption "enable komga container";

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

    # setup containers volume
    system.activationScripts."homelab-komga-volume-setup".text = ''
      # make sure volume path exists
      mkdir -p ${volume-config}
      mkdir -p ${volume-data}
    '';

    virtualisation.oci-containers.containers."${cfg.container-name}" = {
      image = "gotson/komga:${komga-version}";
      volumes = [
        "${volume-config}:/config"
        "${volume-data}:/data"
      ];
      extraOptions = [
        "--network=${cfg.network}"
        "--ip=${cfg.ip}"
      ];
    };
  };
}
