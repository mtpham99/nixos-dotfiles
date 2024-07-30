# hyprpaper.nix

{ pkgs, config, inputs, ... }:
{
  # symlink wallpaper
  xdg.configFile."hypr/hyprpaper-wallpaper.png".source = ../../../../wallpapers/fish-teal-magenta_3840x2160.png;

  services.hyprpaper = {
    enable = true;
    package = inputs.hyprpaper.packages."${pkgs.system}".hyprpaper;

    settings = {
      ipc = "on";
      splash = false;

      preload = [
        "${config.xdg.configHome}/hypr/hyprpaper-wallpaper.png"
      ];

      wallpaper = [
        ", ${config.xdg.configHome}/hypr/hyprpaper-wallpaper.png"
      ];
    };
  };
}