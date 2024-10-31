# steam.nix
# includes gamemoderun and gamescope
# basic usage: add "gamescope -H HEIGHT -W WIDTH --fullscreen -- gamemoderun %command%"
#              to steam game's launch options

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

    programs.gamescope = {
      enable = true;
      capSysNice = false; # TBD: causing issues (multiple github/nixos-discourse mentions)
    };

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = false;
      localNetworkGameTransfers.openFirewall = false;
    };

    programs.gamemode = {
      enable = true;
      enableRenice = true;

      settings = {
        general.inhibit_screensaver = 0;
      };
    };
  };
}
