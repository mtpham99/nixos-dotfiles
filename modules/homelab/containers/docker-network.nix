# docker-network.nix

{ lib, pkgs, config, ... }:
let
  cfg = config.homelab.containers.docker-network;
in 
{
  # expose the `config.docker.package` to find docker executable
  imports = [ ../../nixos/docker.nix ];

  options.homelab.containers.docker-network = {
    enable = lib.mkEnableOption "create docker network";

    network-driver = lib.mkOption {
      type = lib.types.enum [ "macvlan" "ipvlan" ];
      description = "macvlan or ipvlan network driver";
    };
    network-name = lib.mkOption {
      type = lib.types.str;
      description = "network's name";
    };
    interface = lib.mkOption {
      type = lib.types.str;
      description = "network's parent interface";
    };
    gateway = lib.mkOption {
      type = lib.types.str;
      description = "gateway";
    };
    subnet = lib.mkOption {
      type = lib.types.str;
      description = "subnet";
    };
    ip-range = lib.mkOption {
      type = lib.types.str;
      description = "ip range";
    };

    enable-bridge = lib.mkEnableOption "create bridge to allow host to commnuicate with containers";
    bridge-name = lib.mkOption {
      type = lib.types.str;
      description = "bridge interface's name";
      default = "${cfg.network-name}-br";
    };
    bridge-ip = lib.mkOption {
      type = lib.types.str;
      description = "bridge interface's ip address";
    };
    bridge-routes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "list of ip addresses to route via bridge";
      default = [];
      internal = true;
    };
  };

  config = lib.mkIf cfg.enable {

    # create docker/podman network
    systemd.services."homelab-containers-network" = {
      description = "Create homelab containers network";
      after = (
        if config.docker.use-podman then
          [ "podman.service" "podman.socket" ]
        else
          [ "docker.service" "docker.socket" ]
      );
      script = ''
        if ${config.docker.binaryPackage}/bin/docker network ls | grep -q ${cfg.network-name}; then
          echo '"${cfg.network-name}" already exists. Removing.'
          ${config.docker.binaryPackage}/bin/docker network rm ${cfg.network-name} > /dev/null 2>&1
        fi

        echo 'Creating network: "${cfg.network-name}"'
        ${config.docker.binaryPackage}/bin/docker network create \
          --driver=${cfg.network-driver} \
          --gateway=${cfg.gateway} \
          --subnet=${cfg.subnet} \
          --ip-range=${cfg.ip-range} \
          --opt parent=${cfg.interface} \
          ${cfg.network-name} > /dev/null 2>&1
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        ExecStop = "${config.docker.binaryPackage}/bin/docker network rm ${cfg.network-name}";
      };
      wantedBy = [ "multi-user.target" ];
    };

    # ipvlan bridge
    # no ipvlan option under "networking"
    # manually create using systemd unit
    systemd.services."create-${cfg.bridge-name}" = lib.mkIf (cfg.enable-bridge && (cfg.network-driver == "ipvlan")) {
      description = "Create homelab container ipvlan bridge interface";
      after = [ "network.target" ];
      wants = [ "network-online.target" ];
      script = ''
        if ${pkgs.iproute2}/bin/ip link | grep -q ${cfg.bridge-name}; then
          ${pkgs.iproute2}/bin/ip link delete ${cfg.bridge-name} > /dev/null 2>&1
        fi

        ${pkgs.iproute2}/bin/ip link add link ${cfg.interface} name ${cfg.bridge-name} type ipvlan mode l2 bridge
        ${pkgs.iproute2}/bin/ip addr add ${cfg.bridge-ip} dev ${cfg.bridge-name}
        ${pkgs.iproute2}/bin/ip link set ${cfg.bridge-name} up

        ${lib.concatStringsSep "\n"
          (
            map (route-addr:
              "${pkgs.iproute2}/bin/ip route add ${route-addr} dev ${cfg.bridge-name}"
            ) cfg.bridge-routes
          )
        }
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStop = "${pkgs.iproute2}/bin/ip link delete ${cfg.bridge-name}";
      };
      wantedBy = [ "multi-user.target" ];
    };

    # macvlan bridge
    networking = lib.mkIf (cfg.enable-bridge && (cfg.network-driver == "macvlan")) {
      macvlans."${cfg.bridge-name}" = {
        interface = cfg.interface;
        mode = "bridge";
      };
      interfaces."${cfg.bridge-name}" = {
        ipv4 = {
          addresses = [
            {
              address = "${cfg.bridge-ip}";
              prefixLength = 32;
            }
          ];
          routes = lib.map (
            ip: { address = ip; prefixLength = 32; }
          ) cfg.bridge-routes;
        };
      };
    };
  };
}
