# default.nix (wireguard)

{ lib, pkgs, config, ... }:
let
  cfg = config.homelab.containers.wireguard;

  wireguard-version = "1.0.20210914-r4-ls77";

  # volumes
  volume = "/srv/wireguard";

  # add config files to nix store
  wireguard-configs-pkg = pkgs.runCommand "homelab-wireguard-configs" {
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

  options.homelab.containers.wireguard = {
    enable = lib.mkEnableOption "enable wireguard container";

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

    dns = lib.mkOption {
      type = lib.types.str;
      description = "dns used by peers";
      default = "auto";
    };
  };

  config = lib.mkIf cfg.enable {
    # add route for container ip via bridge device
    homelab.containers.docker-network.bridge-routes = lib.mkIf (cfg.add-to-bridge && config.homelab.containers.docker-network.enable-bridge) [ cfg.ip ];

    # setup container's volume
    system.activationScripts."homelab-wireguard-volume-setup".text = ''
      # make sure volume path exists
      mkdir -p ${volume}
    '';

    virtualisation.oci-containers.containers."${cfg.container-name}" = {
      image = "linuxserver/wireguard:${wireguard-version}";
      volumes = [ "${volume}:/config" ];
      environment = { PEERDNS = cfg.dns; };
      environmentFiles = [ "${wireguard-configs-pkg}/ruylopez-wg.env" ];
      extraOptions = [
        "--network=${cfg.network}"
        "--ip=${cfg.ip}"
        "--cap-add=NET_ADMIN"
        "--cap-add=NET_RAW"
        "--sysctl=net.ipv4.ip_forward=1"
      ];
    };
  };
}
