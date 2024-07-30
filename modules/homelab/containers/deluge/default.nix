# default.nix (deluge)

{ lib, config, ... }:
let
  cfg = config.homelab.containers.deluge;

  # volumes
  volume-config = "/srv/deluge/config";
  volume-downloads = "/srv/deluge/downloads";
in
{
  options.homelab.containers.deluge = {
    enable = lib.mkEnableOption "enable deluge container";

    container-name = lib.mkOption {
      type = lib.types.str;
      description = "container's name";
    };

    network-container = lib.mkOption {
      type = lib.types.str;
      description = "container to use for network stack";
    };
  };

  config = lib.mkIf cfg.enable {
    # setup container's volume
    system.activationScripts."homelab-deluge-volume-setup".text = ''
      # make sure volume path exists
      mkdir -p ${volume-config}
      mkdir -p ${volume-downloads}
    '';

    virtualisation.oci-containers.containers."${cfg.container-name}" = {
      image = "linuxserver/deluge:latest";
      volumes = [
        "${volume-config}:/config"
        "${volume-downloads}:/downloads"
      ];
      dependsOn = [ "${cfg.network-container}" ];
      extraOptions = [
        "--network=container:${cfg.network-container}"
      ];
    };
  };
}
