# default.nix (unbound)

{ lib, pkgs, config, ... }:
let
  cfg = config.homelab.containers.unbound;

  # volumes
  volume = "/srv/unbound";

  # add config files to nix store
  unbound-configs-pkg = pkgs.runCommand "homelab-unbound-configs" {
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

  options.homelab.containers.unbound = {
    enable = lib.mkEnableOption "enable unbound container";

    container-name = lib.mkOption {
      type = lib.types.str;
      description = "container's name";
    };

    custom-config = lib.mkOption {
      type = lib.types.str;
      description = "custom config file written to ${volume}/custom.conf";
      default = "";
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
    system.activationScripts."homelab-unbound-volume-setup".text = ''
      # make sure volume path exists
      mkdir -p ${volume}/configs

      # bind mount (read only) config file
      if mountpoint -q ${volume}/unbound.conf; then
        umount ${volume}/unbound.conf
      fi

      touch ${volume}/unbound.conf
      mount --bind --options ro ${unbound-configs-pkg}/unbound.conf ${volume}/unbound.conf

      # write custom config file
      # make sure it is included in ${unbound-configs-pkg}/unbound.conf
      echo -n "${cfg.custom-config}" > ${volume}/configs/custom.conf
    '';

    virtualisation.oci-containers.containers."${cfg.container-name}" = {
      image = "mvance/unbound:latest";
      volumes = [ "${volume}:/opt/unbound/etc/unbound" ];
      extraOptions = [
        "--network=${cfg.network}"
        "--ip=${cfg.ip}"
      ];
    };
  };
}
