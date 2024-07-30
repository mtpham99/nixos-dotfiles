# brightness.nix

{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    papirus-icon-theme
    libnotify # notify-send
    brightnessctl # backlight control
  ];

  home.file.".local/bin/brightness.sh".text = ''
    #!/usr/bin/env sh
    # credit to https://github.com/JaKooLit

    get_brightness() {
      echo $(brightnessctl --machine-readable | cut -d, -f4)
    }

    get_brightness_icon() {
      brightness=$(get_brightness)
      if [ "''${brightness%\%}" -le 33 ]; then
        echo "${pkgs.papirus-icon-theme}/share/icons/Papirus/16x16/panel/brightness-low-symbolic.svg"
      elif [ "''${brightness%\%}" -le 66 ]; then
        echo "${pkgs.papirus-icon-theme}/share/icons/Papirus/16x16/panel/brightness-medium-symbolic.svg"
      else
        echo "${pkgs.papirus-icon-theme}/share/icons/Papirus/16x16/panel/brightness-high-symbolic.svg"
      fi
    }

    notify_brightness() {
      notify-send \
        --transient \
        --hint string:x-canonical-private-synchronous:brightness-notif \
        --hint int:value:$(get_brightness | sed 's/%//') \
        --urgency low \
        --expire-time 2000 \
        --icon "$(get_brightness_icon)" \
        "Brightness: $(get_brightness)"
    }

    change_brightness() {
      change=$1
      brightnessctl set $change
      notify_brightness
    }

    if [ "$1" = "--get" ]; then
      get_brightness
    elif [ "$1" = "--inc" ]; then
      change_brightness "+5%"
    elif [ "$1" = "--dec" ]; then
      change_brightness "5%-"
    else
      get_brightness
    fi
  '';
}
