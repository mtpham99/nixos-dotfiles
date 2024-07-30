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
      width = 0;
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
        justify = "center";
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
        justify = "center";
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
        justify = "center";
      };

      tray = {
        icon-size = 16;
        spacing = 4;
        justify = "center";
      };

      cpu = {
        interval = 5;
        format = " CPU \n{usage:2}%";
        format-alt = " CPU \n{avg_frequency:1.2f}\nGHz";
        on-click = "";
        tooltip = true;
        justify = "center";
      };

      memory = {
        interval = 5;
        format = " RAM \n{percentage:2}%";
        format-alt = " SWAP \n{swapPercentage:2}%";
        on-click = "";
        tooltip = true;
        tooltip-format = "RAM: {used}/{total} GiB ({percentage}%)\nSWAP: {swapUsed}/{swapTotal} GiB ({swapPercentage}%)";
        justify = "center";
      };

      battery = {
        interval = 5;
        states = {
          warning = 30;
          critical = 15;
        };
        format = " {icon} \n{capacity}%";
        format-charging = " 󱘖 \n{capacity}%";
        format-plugged = " 󱘖 \n{capacity}%";
        format-icons = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
        on-click = "";
        tooltip = false;
        justify = "center";
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
        justify = "center";
      };

      "clock#date" = {
        interval = 1;
        format = "{:%a\n%d\n%b\n%y}";
        format-alt = "{:%d\n%m\n%y}";
        tooltip = true;
        tooltip-format = "{calendar}";
        calendar = {
          mode = "month";
          format = {
            today = "<span color='#${colors.text-highlight}'><b>{}</b></span>";
          };
        };
        justify = "center";
      };

      inhibitor = {
        what = "idle";
        format = "{icon}";
        format-icons = {
          activated = "";
          deactivated = "";
        };
        justify = "center";
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

      .modules-left {
        margin-top: 0.3rem;
      }
      .modules-right {
        margin-bottom: 0.5rem;
      }

      #clock,
      #clock.date {
        font-size: 1.05rem;

        padding: 0.3rem 0rem;
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
        padding: 0.3rem 0rem;
      }
    '';
  };
}
