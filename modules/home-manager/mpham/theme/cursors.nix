# cursors.nix

{ lib, pkgs, config, inputs, ... }:
let
  cfg = config.cursors;
in 
{
  imports = [
    inputs.hyprcursor-phinger.homeManagerModules.hyprcursor-phinger
  ];

  options.cursors = {
    enable-hyprcursor = lib.mkEnableOption "enable hyprcursors format";
  };

  config = {
    # xcursor/gtk
    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      name = "phinger-cursors-dark";
      package = pkgs.phinger-cursors;
      size = 24;
    };

    # hyprcursor
    programs.hyprcursor-phinger.enable = cfg.enable-hyprcursor;
    home.sessionVariables = lib.mkIf cfg.enable-hyprcursor {
      HYPRCURSOR_THEME = "phinger-cursors-dark";
      HYPRCURSOR_SIZE = 24;
    };
  };
}
