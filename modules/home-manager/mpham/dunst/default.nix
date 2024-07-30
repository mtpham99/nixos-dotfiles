# default.nix (dunst)

{ lib, pkgs, config, ... }:
let
  colors = import ../theme/colors.nix { inherit lib; };
in 
{
  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "Iosevka" ];})
  ];

  services.dunst = {
    enable = true;

    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
      size = "16x16";
    };

    configFile = "${config.xdg.configHome}/dunst/dunstrc";
    settings = let
      truncateDecimal = float: lib.strings.toInt (builtins.substring 0 (lib.lists.findFirstIndex (c: c == ".") null (lib.strings.stringToCharacters (builtins.toString float))) (builtins.toString float));
      rgbaToTransparency = rgba: (truncateDecimal (100.0 * (1.0 - ((colors.hexStrToInt (colors.getAlpha rgba)) / 255.0))));
    in {
      global = {
        origin = "top-right";
        width = 300;
        height = 100;
        offset = "15x15";

        gap_size = 5;
        frame_width = 3;

        font = "Iosevka NFP Medium 12";

        foreground = "#${colors.rgbaToRgb colors.text}";
        background = "#${colors.rgbaToRgb colors.background}";
      };

      urgency_low = {
        frame_color = "#${colors.rgbaToRgb colors.border-inactive}";
      };

      urgency_normal = {
        frame_color = "#${colors.rgbaToRgb colors.border}";
      };

      urgency_critical = {
        frame_color = "#${colors.rgbaToRgb colors.error}";
      };
    };
  };
}
