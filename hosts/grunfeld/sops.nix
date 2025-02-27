# sops.nix

{ ... }:

{
  sops = {
    gnupg.home = null;
    gnupg.sshKeyPaths = [];
    age.keyFile = "/etc/sops/age/keys.txt";
    age.sshKeyPaths = [];

    defaultSopsFormat = "yaml";

    secrets = {
      # users passwords
      mpham-hashed-user-pass = {
        sopsFile = ../../sops-nix/secrets/grunfeld.yaml;
        neededForUsers = true;
      };

      # duckdns token
      duckdns-token.sopsFile = ../../sops-nix/secrets/common.yaml;

      # samba share credentials
      samba-ruylopez-admin-creds.sopsFile = ../../sops-nix/secrets/common.yaml;

      # wireguard secret/private keys
      wg-protonvpn-chicago117-sk.sopsFile = ../../sops-nix/secrets/wireguard.yaml;
      wg-protonvpn-ch125-sk.sopsFile = ../../sops-nix/secrets/wireguard.yaml;
      wg-protonvpn-uk215-sk.sopsFile = ../../sops-nix/secrets/wireguard.yaml;
      wg-protonvpn-us_iceland1-sk.sopsFile = ../../sops-nix/secrets/wireguard.yaml;

      # homelab vpns shadowsocks proxies
      gluetun-protonvpn-chicago117-socks-json = {
        sopsFile = ../../sops-nix/secrets/homelab.yaml;
        path = "/etc/shadowsocks-rust/gluetun-protonvpn-chicago117.json";
      };
      gluetun-protonvpn-swiss125-socks-json = {
        sopsFile = ../../sops-nix/secrets/homelab.yaml;
        path = "/etc/shadowsocks-rust/gluetun-protonvpn-swiss125.json";
      };
      gluetun-protonvpn-uk215-socks-json = {
        sopsFile = ../../sops-nix/secrets/homelab.yaml;
        path = "/etc/shadowsocks-rust/gluetun-protonvpn-uk215.json";
      };
      gluetun-protonvpn-usiceland1-socks-json = {
        sopsFile = ../../sops-nix/secrets/homelab.yaml;
        path = "/etc/shadowsocks-rust/gluetun-protonvpn-usiceland1.json";
      };

      # homelab wireguard server (grunfeld peer sk)
      ruylopez-wireguard-grunfeld-peer-sk = {
        sopsFile = ../../sops-nix/secrets/homelab.yaml;
      };
    };
  };
}
