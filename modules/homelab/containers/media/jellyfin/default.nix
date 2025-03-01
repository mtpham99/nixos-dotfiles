# default.nix (jellyfin)

{ lib, pkgs, config, ... }:
let
  cfg = config.homelab.containers.jellyfin;

  jellyfin-version = "10.10";

  # volumes
  volume-media = "/srv/jellyfin/media";
  volume-config = "/srv/jellyfin/config";
  volume-cache = "/srv/jellyfin/cache";
in
{
  imports = [
    ../../docker-network.nix # add route for container ip via bridge
  ];

  options.homelab.containers.jellyfin = {
    enable = lib.mkEnableOption "enable jellyfin container";

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
    system.activationScripts."homelab-jellyfin-volume-setup".text = ''
      # make sure volume path exists
      mkdir -p ${volume-media}
      mkdir -p ${volume-config}
      mkdir -p ${volume-cache}
    '';

    virtualisation.oci-containers.containers."${cfg.container-name}" = {
      image = "jellyfin/jellyfin:${jellyfin-version}";
      volumes = [
        "${volume-media}:/media"
        "${volume-config}:/config"
        "${volume-cache}:/cache"
      ];
      extraOptions = [
        "--network=${cfg.network}"
        "--ip=${cfg.ip}"
        "--gpus=all"
      ];
    };
  };
}
