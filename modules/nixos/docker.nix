# docker.nix

{ lib, pkgs, config, ... }:
let
  podmanPackage = (pkgs.podman.override {
    extraPackages = config.virtualisation.podman.extraPackages
      # setuid shadow
      ++ [ "/run/wrappers" ]
      ++ lib.optional (config.boot.supportedFilesystems.zfs or false) config.boot.zfs.package;
  });
  dockerCompat = pkgs.runCommand "${podmanPackage.pname}-docker-compat-${podmanPackage.version}"
    {
      outputs = [ "out" "man" ];
      inherit (podmanPackage) meta;
    } ''
    mkdir -p $out/bin
    ln -s ${podmanPackage}/bin/podman $out/bin/docker

    mkdir -p $man/share/man/man1
    for f in ${podmanPackage.man}/share/man/man1/*; do
      basename=$(basename $f | sed s/podman/docker/g)
      ln -s $f $man/share/man/man1/$basename
    done
  '';

  cfg = config.docker;
in
{
  options.docker = {
    enable = lib.mkEnableOption "enable docker";

    rootless = lib.mkEnableOption "enable rootless docker (no affect when using podman)";
    use-nvidia = lib.mkEnableOption "enable nvidia-container-toolkit";
    use-podman = lib.mkEnableOption "enable podman as docker drop-in replacement";

    # expose the package providing the `docker` executable
    # this is useful for finding the fake `docker`
    # executable when using podman as a drop-in replacement
    binaryPackage = lib.mkOption {
      type = lib.types.package;
      description = "package providing the \"docker\" executable";
      default = if cfg.use-podman then dockerCompat else config.virtualisation.docker.package;
      internal = true;
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.containers.enable = true;

    virtualisation = {
      docker = {
        enable = !cfg.use-podman;

        autoPrune = {
          enable = true;
          dates = "weekly";
        };
        rootless = lib.mkIf cfg.rootless {
          enable = true;
          setSocketVariable = true; 
        };
      };

      podman = lib.mkIf cfg.use-podman {
        enable = cfg.use-podman;
        dockerCompat = true;

        autoPrune = {
          enable = true;
          dates = "weekly";
        };
        defaultNetwork.settings.dns_enable = true;
      };

      oci-containers.backend = if cfg.use-podman then "podman" else "docker";
    };

    hardware.nvidia-container-toolkit.enable = cfg.use-nvidia; # && config.nvidia.enable

    environment.systemPackages = with pkgs; [
      docker-compose
      (lib.mkIf cfg.use-podman podman-tui)
    ];
  };
}
