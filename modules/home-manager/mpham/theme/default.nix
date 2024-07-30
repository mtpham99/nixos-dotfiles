# default.nix (theme)

{ pkgs, ... }:

{
  imports = [
    ./fonts.nix
    ./icons.nix
    ./cursors.nix
  ];

  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
  };

  qt = {
    enable = true;
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };
}
