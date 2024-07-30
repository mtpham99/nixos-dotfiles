# default.nix (waybar)

{ lib, pkgs, ... }:
let
  colors = import ../theme/colors.nix { inherit lib; };
in
{
  imports = [
    ../scripts/volume.nix
  ];

  home.packages = with pkgs; [
    pavucontrol
    blueman
    (nerdfonts.override { fonts = [ "Iosevka" ];})
  ];

  programs.waybar = {
    enable = true;

    settings.main-bar = {
      layer = "top";
      position = "left";
      width = 20;
      margin-top = 3;
      margin-bottom = 3;
      margin-left = 3;
      margin-right = 3;
      spacing = 0;
      gtk-layer-shell = false;

      modules-left = [
        "clock"
        "clock#date"
      ];

      modules-center = [
        "hyprland/workspaces"
      ];

      modules-right = [
        "battery"
        "cpu"
        "memory"
        "pulseaudio#sink"
        "pulseaudio#source"
        "inhibitor"
        "tray"
      ];

    } // { # modules
      "pulseaudio#sink" = {
        format = " {icon} \n{volume}%";
        format-bluetooth = " 󰂯{icon} \n{volume}%";
        format-bluetooth-muted = "󰂯󰖁";
        format-muted = "󰖁";
        format-icons = {
            headphone = "󰋋";
            hands-free = "󰋋";
            headset = "󰋋";
            phone = "";
            portable = "";
            car = "";
            default = ["󰕿" "󰖀" "󰕾"];
        };
        on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
        on-middle-click = "sh \${HOME}/.local/bin/volume.sh --toggle";
        on-scroll-up = "sh \${HOME}/.local/bin/volume.sh --inc";
        on-scroll-down = "sh \${HOME}/.local/bin/volume.sh --dec";
        tooltip = false;
      };

      "pulseaudio#source" = {
        format = "{format_source}";
        format-source = " 󰍬 \n{volume}%";
        format-source-muted = "󰍭";
        on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
        on-middle-click = "sh \${HOME}/.local/bin/volume.sh --toggle-mic";
        on-scroll-up = "sh \${HOME}/.local/bin/volume.sh --inc-mic";
        on-scroll-down = "sh \${HOME}/.local/bin/volume.sh --dec-mic";
        tooltip = false;
      };

      "hyprland/workspaces" = {
        format = "{icon}";
        format-icons = {
            "1" = 1;
            "2" = 2;
            "3" = 3;
            "4" = 4;
            "5" = 5;
            "6" = 6;
            "7" = 7;
            "8" = 8;
            "9" = 9;
            default = 1;
        };
        persistent-workspaces = {
          "*" = [ 1 2 3 4 5 ];
        };
        on-click = "activate";
        on-scroll-up = "hyprctl dispatch workspace e-1";
        on-scroll-down = "hyprctl dispatch workspace e+1";
      };

      tray = {
        icon-size = 16;
        spacing = 8;
      };

      cpu = {
        interval = 5;
        format = "CPU\n{usage:2}%";
        format-alt = "CPU\n{avg_frequency:1.2f}\nGHz";
        on-click = "";
        tooltip = true;
      };

      memory = {
        interval = 5;
        format = "RAM\n{percentage:2}%";
        format-alt = "Swap\n{swapPercentage:2}%";
        on-click = "";
        tooltip = true;
        tooltip-format = "RAM: {used}/{total} GiB ({percentage}%)\nSwap: {swapUsed}/{swapTotal} GiB ({swapPercentage}%)";
      };

      battery = {
        states = {
          warning = 30;
          critical = 15;
        };
        format = " {icon} \n{capacity}%";
        format-charging = " 󰂄 \n{capacity}%";
        format-plugged = " 󱘖 \n{capacity}%";
        format-icons = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
        on-click = "";
        tooltip = false;
      };

      clock = {
        interval = 1;
        format = "{:%H\n%M\n%S}";
        # format-alt = "{:%Z\n%I\n%M\n%S\n%p}";
        format-alt = "{:%Z\n%H\n%M\n%S}";
        tooltip = true;
        tooltip-format = "{tz_list}";
        timezones = [
          "America/Chicago"
          "Etc/UTC"
          "America/New_York"
          "America/Los_Angeles"
          "Europe/London"
          "Europe/Paris"
          "Asia/Tokyo"
          "Australia/Sydney"
        ];
      };

      "clock#date" = {
        interval = 1;
        format = "{:%d\n%m\n%y}";
        format-alt = "{:%a\n%d\n%b\n%y}";
        tooltip = true;
        tooltip-format = "{calendar}";
        calendar = {
          mode = "month";
          format = {
            today = "<span color='#${colors.text-highlight}'><b>{}</b></span>";
          };
        };
      };

      inhibitor = {
        what = "idle";
        format = "{icon}";
        format-icons = {
          activated = "";
          deactivated = "";
        };
      };
    };

    style = ''
      * {
        font-family: "Iosevka NFP ExtraBold";
        font-size: 1rem;
        color: ${colors.toCssRgba colors.text};

        padding: 0rem 0rem;
        margin: 0rem 0rem;
      }

      window#waybar {
        background: ${colors.toCssRgba colors.background};
        border-radius: 0.5rem;
        border: 0.15rem solid ${colors.toCssRgba colors.border};
      }

      #clock {
        margin-top: 0.2rem;
      }
      #clock,
      #clock.date {
        padding: 0.3rem 0.2rem;
        margin: 0rem 0rem;
      }

      #workspaces {
      }
      #workspaces button {
        border-radius: 0.5rem;
        border: 0.15rem solid transparent;
      }
      #workspaces button.active {
        border-radius: 0.5rem;
        border: 0.15rem solid ${colors.toCssRgba colors.border};
      }
      #workspaces button:hover {
        border-radius: 0.5rem;
        border: 0.15rem solid ${colors.toCssRgba colors.border};
      }

      #battery,
      #cpu,
      #memory,
      #pulseaudio.sink,
      #pulseaudio.source,
      #tray {
        padding: 0.3rem 0.2rem;
      }
      #tray {
        margin-bottom: 0.2rem;
      }
    '';
  };
}
