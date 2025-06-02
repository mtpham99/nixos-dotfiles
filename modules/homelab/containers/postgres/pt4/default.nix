# default.nix (postgres/pt4)
# note: database must manually be created using pokertracker4

{ lib, pkgs, config, ... } :
let
  cfg = config.homelab.containers.postgres.pt4;

  postgres-version = "9.3.25";

  # volumes
  volume-data = "/srv/postgres/pt4/data";
  volume-config = "/srv/postgres/pt4/config";

  # add config files to nix store
  postgres-pt4-configs-pkg = pkgs.runCommand "" {
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

  options.homelab.containers.postgres.pt4 = {
    enable = lib.mkEnableOption "enable pokertracker4 (pt4) postgres database";

    container-name = lib.mkOption {
      type = lib.types.str;
      description = "container's name";
      default = "postgres-pt4";
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
    system.activationScripts."homelab-postgres-pt4-volume-setup".text = ''
      mkdir -p ${volume-data}

      mkdir -p ${volume-config}
      if mountpoint -q ${volume-config}/pt4.conf; then
        umount ${volume-config}/pt4.conf
      fi
      touch ${volume-config}/pt4.conf
      mount --bind --options ro ${postgres-pt4-configs-pkg}/pt4.conf ${volume-config}/pt4.conf
    '';

    virtualisation.oci-containers.containers."${cfg.container-name}" = {
      image = "docker.io/postgres:${postgres-version}-alpine";
      volumes = [
        "${volume-data}:/var/lib/postgresql/data"
        "${volume-config}/pt4.conf:/etc/postgresql/postgresql.conf"
      ];
      environment = {
        # change name of default/dummy database
        # actual pt4 database needs to be created manually using pokertracker4
        POSTGRES_DB = "postgres";
      };
      environmentFiles = [
        config.sops.secrets.postgres-pt4-creds-env.path
      ];
      extraOptions = [
        "--network=${cfg.network}"
        "--ip=${cfg.ip}"
      ];
    };
  };
}
