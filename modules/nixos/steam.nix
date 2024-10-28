# steam.nix

{ lib, pkgs, config, ... }:
let
  cfg = config.steam;
in
{
  options = {
    steam = {
      enable = lib.mkEnableOption "enable steam";
    };
  };

  config = lib.mkIf cfg.enable {
    allowedUnfree = [
      "steam"
      "steam-original"
      "steam-unwrapped"
      "steam-run"
    ];

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = false;
      localNetworkGameTransfers.openFirewall = false;
    };
  };
}
