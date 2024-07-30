# thunar.nix

{ lib, config, pkgs, ... }:
let
  cfg = config.thunar;
in 
{
  options = {
    thunar = {
      enable = lib.mkEnableOption "enable thunar";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.xfconf.enable = true; # required if not using xfce
    programs.thunar = {
      enable = true;

      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };

    # thumbnail support
    services.tumbler.enable = true;

    # mount, trash, and other functionalities
    services.gvfs.enable = true;
  };
}
