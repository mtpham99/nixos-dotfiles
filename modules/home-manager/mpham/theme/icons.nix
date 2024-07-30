# icons.nix

{ pkgs, ... }:

{
  gtk.enable = true;
  gtk.iconTheme = {
    name = "Papirus";
    package = pkgs.papirus-icon-theme;
  };
}
