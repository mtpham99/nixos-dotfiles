# rofi.nix

{ pkgs, ... }:

{
  imports = [
    ../rofi
  ];

  home.packages = with pkgs; [
    wl-clipboard
    cliphist
  ];

  home.file.".local/bin/rofi.sh".text = ''
    #!/usr/bin/env sh

    drun_calc_emoji() {
      mode=$1
      rofi \
        -modes "drun,calc,emoji" -show "$mode" \
        -terse -no-show-match -no-sort -calc-command-history -calc-command "echo -n '{result}' | wl-copy"
    }

    clipboard() {
      cliphist list | rofi -dmenu | cliphist decode | wl-copy
    }

    if [ "$1" = "--drun" ] || [ "$1" = "--calc" ] || [ "$1" = "--emoji" ]; then
      drun_calc_emoji "''${1#--}"
    elif [ "$1" = "--clipboard" ]; then
      clipboard
    else
      drun_calc_emoji "drun"
    fi
  '';
}
