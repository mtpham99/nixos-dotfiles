# shadowsocks-rust.nix

{ lib, pkgs, config, ... }:
let
  cfg = config.shadowsocks-rust;
  toAttrsFn = names: lib.listToAttrs (lib.map (name: { name = name; value = {}; }) names);
in
{
  options = {
    shadowsocks-rust = {
      enable = lib.mkEnableOption "enable shadowsocks-rust";

      client-configs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "list of configs names that will be found at `/etc/shadowsocks-rust/{CONFIGNAME}.json`";
        default = [];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ shadowsocks-rust ];

    systemd.services = lib.mapAttrs (service-name: _: {
      unitConfig = {
        Description = "Shadowsocks-Rust Client Service";
        After = [ "network.target" ];
        Wants = [ "network-online.target" ];
      };
      serviceConfig = {
        Type = "simple";
        AmbientCapabilities = "CAP_NET_BIND_SERVICE CAP_NET_ADMIN";
        ExecStart = "${pkgs.shadowsocks-rust}/bin/ssservice local --log-without-time -c /etc/shadowsocks-rust/%i.json";
        Restart = "on-failure";
      };
      wantedBy = [ "multi-user.target" ];
    }) (toAttrsFn (lib.map (
      config-name: "shadowsocks-rust@${config-name}"
    ) cfg.client-configs));
  };
}
