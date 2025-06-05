# default.nix (github_exporter)

{ lib, pkgs, config, ... }:
let
  cfg = config.homelab.containers.github_exporter;

  # add config files to nix store
  github-exporter-configs-pkg = pkgs.runCommand "" {
    buildInputs = [ pkgs.coreutils ];
    src = ./configs;
  } ''
    cp -r $src/. $out/
  '';

  github_exporter-version = "1.3.1";
in
{
  options.homelab.containers.github_exporter = {
    enable = lib.mkEnableOption "enable github exporter container";

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
      image = "docker.io/githubexporter/github-exporter:${github_exporter-version}";
      extraOptions = [
        "--network=${cfg.network}"
        "--ip=${cfg.ip}"
      ];
      environmentFiles = [
        "${github-exporter-configs-pkg}/mtpham99.env"
        config.sops.secrets.github-mtpham99-token.path # GITHUB_TOKEN=...
      ];
    };
  };
}
