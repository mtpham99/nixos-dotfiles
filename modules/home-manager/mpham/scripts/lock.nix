# lock.nix

{ ... }:

{
  imports = [
    ../hyprland/hyprlock.nix
  ];

  home.file.".local/bin/lock.sh".text = ''
    #!/usr/bin/env bash
    # credit to https://github.com/JaKooLit

    pidof hyprlock || hyprlock -q
  '';
}
