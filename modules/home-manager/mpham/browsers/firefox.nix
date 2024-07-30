# firefox.nix

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    firefox
  ];
}
