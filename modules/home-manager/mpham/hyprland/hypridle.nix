# hypridle.nix

{ pkgs, config, inputs, ... }:

{
  imports = [
    ../scripts/lock.nix
  ];

  home.packages = [
    pkgs.brightnessctl # backlight control
  ];

  services.hypridle = {
    enable = true;
    package = inputs.hypridle.packages."${pkgs.system}".hypridle;

    settings = {
      general = {
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
        lock_cmd = "exec sh \${HOME}/.local/bin/lock.sh";
      };

      listener = [
        # dim display
        {
          timeout = 300;
          on-timeout = "brightnessctl -s set 5%";
          on-resume = "brightnessctl -r";
        }

        # dim beyboard
        {
          timeout = 300;
          on-timeout = "brightnessctl -s -d tpacpi::kbd_backlight set 0";
          on-resume = "brightnessctl -r -d tpacpi::kbd_backlight";
        }

        # lock screen
        {
          timeout = 600;
          on-timeout = "loginctl lock-session";
        }

        # turn off display
        {
          timeout = 720;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }

        # suspend
        {
          timeout = 1200;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
