# sops.nix

{ ... }:

{
  # sops-nix secrets config
  sops = {
    gnupg.home = null;
    gnupg.sshKeyPaths = [];
    age.keyFile = /root/sops/age/keys.txt;
    age.sshKeyPaths = [];

    defaultSopsFormat = "yaml";

    secrets = {
      # users passwords
      admin-hashed-user-pass = {
        sopsFile = ../../sops-nix/secrets/ruylopez.yaml;
        neededForUsers = true;
      };

      # duckdns token
      duckdns-token = {
        sopsFile = ../../sops-nix/secrets/common.yaml;
      };

      # samba shares
      samba-ruylopez-admin-creds = {
        sopsFile = ../../sops-nix/secrets/common.yaml;
      };

      # gluetun container secrets
      gluetun-protonvpn-chicago75-docker-env-secrets = {
        sopsFile = ../../sops-nix/secrets/homelab.yaml;
      };
      gluetun-protonvpn-swiss125-docker-env-secrets = {
        sopsFile = ../../sops-nix/secrets/homelab.yaml;
      };
      gluetun-protonvpn-uk215-docker-env-secrets = {
        sopsFile = ../../sops-nix/secrets/homelab.yaml;
      };
      gluetun-protonvpn-usiceland1-docker-env-secrets = {
        sopsFile = ../../sops-nix/secrets/homelab.yaml;
      };

      # wireguard container secrets
      ruylopez-wireguard-server-url-port-env = {
        sopsFile = ../../sops-nix/secrets/homelab.yaml;
      };
    };
  };
}
