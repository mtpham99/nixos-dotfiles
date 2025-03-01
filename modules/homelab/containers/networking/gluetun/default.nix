# default.nix (gluetun)

{ lib, pkgs, config, ... }:
let
  cfg = config.homelab.containers.gluetun;

  gluetun-version = "3.40";

  # add config files to nix store
  gluetun-configs-pkg = pkgs.runCommand "homelab-gluetun-configs" {
    buildInputs = [ pkgs.coreutils ];
    src = ./configs;
  } ''
    cp -r $src/. $out/
  '';

  # helper to create `virtualisation.oci-containers.containers.<name>` container config
  createContainerConfig = container: {
    image = "qmcgaw/gluetun:v${gluetun-version}";
    environmentFiles = container.env-files;
    extraOptions = [
      "--network=${container.network}"
      "--ip=${container.ip}"
      "--device=/dev/net/tun:/dev/net/tun"
      "--cap-add=NET_ADMIN"
    ];
  };

  # helper to get all ips to add route for via bridge
  bridgeIps = containers: lib.filter (ip: ip != null) (
    lib.mapAttrsToList (
      container-name: container: (
        if container.add-to-bridge then container.ip else null
      )
    ) containers
  );
in
{
  imports = [
    ../../docker-network.nix # add route for container ip via bridge
  ];

  options.homelab.containers.gluetun = {
    enable = lib.mkEnableOption "enable gluetun container";

    # expose path to installed configs
    config-pkg = lib.mkOption {
      type = lib.types.path;
      description = "gluetun configs package";
      default = gluetun-configs-pkg;
      internal = true;
    };

    containers = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          env-files = lib.mkOption {
            type = lib.types.listOf lib.types.path;
            description = "container's environment files";
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
      });
    };
  };

  config = lib.mkIf cfg.enable {
    # add route for container ip via bridge device
    homelab.containers.docker-network.bridge-routes = bridgeIps cfg.containers;

    # create all containers
    virtualisation.oci-containers.containers = lib.mapAttrs (
      container-name: container-info: createContainerConfig container-info
    ) cfg.containers;
  };
}
