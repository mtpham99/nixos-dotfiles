# steam.nix
# includes gamemoderun, gamescope, and proton ge
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
      extraCompatPackages = with pkgs; [ proton-ge-bin ];

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
