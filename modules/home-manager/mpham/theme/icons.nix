# icons.nix

{ pkgs, ... }:

{
  gtk.iconTheme = {
    name = "Papirus";
    package = pkgs.papirus-icon-theme;
  };
}
