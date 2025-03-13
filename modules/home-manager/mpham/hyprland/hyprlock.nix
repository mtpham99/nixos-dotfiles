# hyprlock.nix

{ lib, pkgs, config, ... }:
let
  colors = import ../theme/colors.nix { inherit lib; };
in
{
  # symlink lockscreen wallpaper
  xdg.configFile."hypr/hyprlock-background.png".source = ../../../../wallpapers/fish-teal-magenta_3840x2160.png;

  programs.hyprlock = {
    enable = true;
    package = pkgs.hyprlock; # inputs.hyprlock.packages."${pkgs.system}".hyprlock;

    settings = {
      general = {
        ignore_empty_input = true;
      };

      # background
      background = [
        {
          monitor = "";
          path = "${config.xdg.configHome}/hypr/hyprlock-background.png";
        }
      ];

      # display clock/text
      label = [
        # clock
        {
          monitor = "";
          position = "0, -100";
          halign = "center";
          valign = "top";

          text = "cmd[update:1000] echo \"$(date '+%H:%M:%S')\"";
          # font_family =;
          font_size = 64;
          font_color = "rgb(FF0000)";
          # shadow_passes = 1;
        }

        # date
        {
          monitor = "";
          position = "0, 100";
          halign = "center";
          valign = "bottom";

          text = "cmd[update:1000] echo \"$(date '+%A, %d %B %Y')\"";
          # font_family = ;
          font_size = 48;
          font_color = "rgba(${colors.text})";
          # shadow_passes = 1;
        }

        # "hello" $user text
        # {
        #   monitor = "";
        #   position = "0, 50";
        #   halign = "center";
        #   valign = "center";

        #   text = "Hello Matthew...";
        #   # font_family =
        #   font_size = 24;
        #   font_color = "rgba(${colors.text})";
        #   # shadow_passes = 1;
        # }
      ];

      # password input field
      input-field = [
        {
          monitor = "";
          size = "500, 50";
          position = "0, 0";
          halign = "center";
          valign = "center";

          # border color when lock is on (-1 don't change color)
          capslock_color = -1;
          numlock_color = -1;
          bothlock_color = -1;

          rounding = 20;
          outline_thickness = 3;
          # inner_color = ;
          # check_color = ;
          fail_color = "rgba(${colors.error})";
          fail_transition = 200;
          fade_on_empty = true;

          hide_input = false;
          placeholder_text = "<i>Password...</i>";
          fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";

          dots_size = 0.4;
          dots_spacing = 0.5;
          dots_rounding = -1;
          dots_center = true;
        }
      ];
    };
  };
}
