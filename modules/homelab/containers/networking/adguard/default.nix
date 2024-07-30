# default.nix (adguard)

{ lib, pkgs, config, ... }:
let
  cfg = config.homelab.containers.adguard;

  # volumes
  volume-conf = "/srv/adguard/conf";
  volume-work = "/srv/adguard/work";
in 
{
  imports = [
    ../../docker-network.nix # add route for container ip via bridge
  ];

  options.homelab.containers.adguard = {
    enable = lib.mkEnableOption "enable adguard container";

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


    # setup container's volumes
    system.activationScripts."homelab-adguard-volume-setup".text = ''
      # make sure volume paths exist
      mkdir -p ${volume-conf}
      mkdir -p ${volume-work}
    '';

    virtualisation.oci-containers.containers."${cfg.container-name}" = {
      image = "adguard/adguardhome:latest";
      volumes = [
        "${volume-conf}:/opt/adguardhome/conf"
        "${volume-work}:/opt/adguardhome/work"
      ];
      extraOptions = [
        "--network=${cfg.network}"
        "--ip=${cfg.ip}"
        "--cap-add=NET_ADMIN"
      ];
    };
  };
}
