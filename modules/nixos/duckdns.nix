# duckdns.nix

{ lib, config, pkgs, ... }:
let
  cfg = config.duckdns;
in 
{
  options = {
    duckdns = {
      enable = lib.mkEnableOption "enable duckdns domain update systemd unit";
      domain = lib.mkOption {
        type = lib.types.str;
        description = "domain name to update";
      };
      token-file = lib.mkOption {
        type = lib.types.path;
        description = "path to a file containing duckdns token";
      };
      log-path = lib.mkOption {
        type = lib.types.str;
        description = "path to log file";
        default = "/var/log/duckdns/duck.log";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # systemd service to run update script
    systemd.services."duckdns" = {
      path = with pkgs; [ curl ];
      description = "updates duckdns domain";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      requires = [ "network-online.target" ];
      script = ''
        # create log dir
        mkdir -p $(dirname "${cfg.log-path}")

        # update ip
        ${pkgs.curl}/bin/curl -k "https://www.duckdns.org/update?domains=${cfg.domain}&token=$(cat ${cfg.token-file})&ip=" -o "${cfg.log-path}"

        # get status
        STATUS=$(cat "${cfg.log-path}")

        # return/check status
        if [ "''${STATUS}" == "OK" ]; then
          echo "OK"
          exit 0
        else
          echo "ERROR"
          exit 1
        fi
      '';
      serviceConfig = {
        Type = "oneshot";
      };
    };

    # systemd timer to run every 5 minutes
    systemd.timers."duckdns" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnUnitActiveSec = "5m";
        Unit = "duckdns.service";
      };
    };
  };
}
