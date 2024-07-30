# hyprland.nix

{ lib, pkgs, config, inputs, ... }:
let
  cfg = config.hyprland;
in
{
  imports = [
    ./wayland.nix
  ];

  options = {
    hyprland = {
      enable = lib.mkEnableOption "enable hyprland";
    };
  };

  config = lib.mkIf cfg.enable {
    # enable hyprland cachix before using hyprland flake package
    # see https://wiki.hyprland.org/Nix/Cachix
    nix.settings = {
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };

    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages."${pkgs.system}".hyprland;
    };
  };
}
