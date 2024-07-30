# volume.nix

{ pkgs, config, ... }:

{
  config.home.packages = with pkgs; [
    papirus-icon-theme
    libnotify # notify-send
    wireplumber # wpctl
  ];

  # volume control script
  # credit to https://github.com/JaKooLit
  config.home.file.".local/bin/volume.sh".text = ''
    #!/usr/bin/env sh
    # credit to https://github.com/JaKooLit

    get_volume() {
      deviceid=$1

      volume=$(wpctl get-volume "''${deviceid}" | sed -n 's/Volume: \([0-9]*\.[0-9]*\) *\([MUTED]\)*/\1 \2/p' | cut -d' ' -f1)
      mute=$(wpctl get-volume "''${deviceid}" | sed -n 's/Volume: \([0-9]*\.[0-9]*\) *\([MUTED]\)*/\1 \2/p' | cut -d' ' -f2)

      if [ "''${volume}" == "0.00" ] || [ -n "''${mute}" ]; then
        echo "Muted"
      else
        echo "$(awk "BEGIN {print $volume * 100}")%"
      fi
    }

    get_icon() {
      deviceid=$1
      volume=$(get_volume "$1")

      if [ "''${deviceid}" == "@DEFAULT_AUDIO_SINK@" ]; then
        if [ "''${volume}" == "Muted" ]; then
          echo "${pkgs.papirus-icon-theme}/share/icons/Papirus/16x16/panel/volume-level-muted.svg"
        elif [ "''${volume%\%}" -le 33 ]; then
          echo "${pkgs.papirus-icon-theme}/share/icons/Papirus/16x16/panel/volume-level-low.svg"
        elif [ "''${volume%\%}" -le 66 ]; then
          echo "${pkgs.papirus-icon-theme}/share/icons/Papirus/16x16/panel/volume-level-medium.svg"
        else
          echo "${pkgs.papirus-icon-theme}/share/icons/Papirus/16x16/panel/volume-level-high.svg"
        fi

      elif [ "''${deviceid}" == "@DEFAULT_AUDIO_SOURCE@" ]; then
        if [ "''${volume}" == Muted ]; then
          echo "${pkgs.papirus-icon-theme}/share/icons/Papirus/16x16/panel/microphone-sensitivity-muted.svg"
        else
          echo "${pkgs.papirus-icon-theme}/share/icons/Papirus/16x16/panel/microphone-sensitivity-high.svg"
        fi

      else
        exit 1
      fi
    }

    notify_volume() {
      deviceid=$1

      if [ "$(get_volume $deviceid)" == "Muted" ]; then
        notify-send \
          --transient \
          --hint=string:x-canonical-private-synchronous:volume_notif \
          --urgency=low \
          --expire-time 2000 \
          --icon "$(get_icon $1)" \
          "Volume: Muted"
      else
        notify-send \
          --transient \
          --hint=int:value:"$(get_volume $deviceid | sed 's/%//')" \
          --hint string:x-canonical-private-synchronous:volume_notif \
          --urgency low \
          --icon "$(get_icon $1)" \
          "Volume: $(get_volume $1)"
      fi
    }

    change_volume() {
      deviceid=$1
      change=$2

      if [ "$(get_volume $deviceid)" == "Muted" ]; then
        wpctl set-mute $deviceid toggle
        notify_volume $deviceid
      fi

      wpctl set-volume --limit 1.5 $deviceid $change
      notify_volume $deviceid
    }

    toggle_mute() {
      deviceid=$1
      wpctl set-mute $deviceid toggle
      notify_volume $deviceid
    }

    if [ "$1" = "--get" ]; then
      get_volume "@DEFAULT_AUDIO_SINK@"
    elif [ "$1" = "--inc" ]; then
      change_volume "@DEFAULT_AUDIO_SINK@" "5%+"
    elif [ "$1" = "--dec" ]; then
      change_volume "@DEFAULT_AUDIO_SINK@" "5%-"
    elif [ "$1" = "--toggle" ]; then
      toggle_mute "@DEFAULT_AUDIO_SINK@"

    elif [ "$1" = "--inc-mic" ]; then
      change_volume "@DEFAULT_AUDIO_SOURCE@" "5%+"
    elif [ "$1" = "--dec-mic" ]; then
      change_volume "@DEFAULT_AUDIO_SOURCE@" "5%-"
    elif [ "$1" = "--toggle-mic" ]; then
      toggle_mute "@DEFAULT_AUDIO_SOURCE@"

    else
      get_volume "@DEFAULT_AUDIO_SINK@"
    fi
  '';
}
