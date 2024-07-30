# sops.nix

{ config, ... }:

{
  sops = {
    gnupg.home = null;
    gnupg.sshKeyPaths = [];
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
    age.sshKeyPaths = [];

    defaultSopsFormat = "yaml";
  }; 
}
