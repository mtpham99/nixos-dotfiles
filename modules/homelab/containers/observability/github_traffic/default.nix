# default.nix (github_traffic)

{ lib, pkgs, config, ... }:
let
  cfg = config.homelab.containers.github_traffic;

  # add config files to nix store
  github-traffic-pkg = pkgs.runCommand "" {
    buildInputs = [ pkgs.coreutils ];
    src = ./configs;
  } ''
    cp -r $src/. $out/
  '';

  github_traffic-version = "0.0.4";
in
{
  options.homelab.containers.github_traffic = {
    enable = lib.mkEnableOption "enable github traffic container";

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
      image = "ghcr.io/grafana/github-traffic:v${github_traffic-version}";
      volumes = [ ];
      extraOptions = [
        "--network=${cfg.network}"
        "--ip=${cfg.ip}"
      ];
      environmentFiles = [
        "${github-traffic-pkg}/mtpham99.env"
        config.sops.secrets.github-traffic-mtpham99-token.path # GITHUB_TOKEN=...
      ];
    };
  };
}
