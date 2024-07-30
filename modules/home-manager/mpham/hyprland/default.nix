# default.nix (hyprland)

{ pkgs, config, inputs, ... }:

{
  imports = [
    ./hyprland.nix
    ./hyprlock.nix
    ./hypridle.nix
    ./hyprpaper.nix
  ];
}
