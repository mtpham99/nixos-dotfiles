# sops.nix

{ ... }:

{
  sops = {
    gnupg.home = null;
    gnupg.sshKeyPaths = [];
    age.keyFile = "/root/sops/age/keys.txt";
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
      gluetun-protonvpn-chicago117-docker-env-secrets = {
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

      # grafana
      grafana-password = {
        sopsFile = ../../sops-nix/secrets/homelab.yaml;
        owner = "grafana"; # 472
        mode = "0440";
      };

      # github traffic (github token env file)
      github-traffic-mtpham99-token = {
        sopsFile = ../../sops-nix/secrets/homelab.yaml;
      };
    };
  };

  # workaround since sops cannot accept arbitrary user/group ids
  # used to set permissions of sercret file mounted by grafana container
  users.users."grafana" = {
    isNormalUser = false;
    createHome = false;
    uid = 472;
    group = "grafana";
  };
  users.groups."grafana" = {
    gid = 472;
  };
}
