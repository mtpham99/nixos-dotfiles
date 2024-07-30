# default.nix (ssh)

{ config, ... }:

{
  # symlink ssh keys
  config.home.file.".ssh/mpham_grunfeld.pub".source = ../../../../ssh-keys/grunfeld.pub;
  config.sops.secrets = {
    ssh-grunfeld-sk = {
      sopsFile = ../../../../sops-nix/secrets/ssh.yaml;
      path = "${config.home.homeDirectory}/.ssh/mpham_grunfeld";
    };
  };

  config.programs.ssh = {
    enable = true;

    addKeysToAgent = "confirm";
    controlMaster = "no"; # autoask
    controlPersist = "no"; # 1m

    extraConfig = ''
      Host *
        IdentityFile ~/.ssh/mpham_grunfeld

      Host grunfeld
        User mtpham
        HostName grunfeld.lan
        Port 22

      Host najdorf
        User mtpham
        HostName najdorf.lan
        Port 22

      Host ruylopez
        User admin
        Hostname ruylopez.lan
        Port 22

      # Host perlmutter*.nersc.gov
      #   User mtpham
      #   controlmaser auto
      #   controlpersist yes

      # Host cori*.nersc.gov
      #   User mtpham
      #   controlmaser auto
      #   controlpersist yes

      # Host midway2*.rcc.uchicago.edu
      #   User mtpham
      #   controlmaser auto
      #   controlpersist yes
    '';
  };
}
