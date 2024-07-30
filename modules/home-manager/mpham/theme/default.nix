# default.nix (theme)

{ config, pkgs, ... }:

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

    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
    gtk3.bookmarks = [
      "file:///home/mpham/downloads"
      "file:///home/mpham/tmp"
      "file:///home/mpham/documents"
      "file:///home/mpham/projects"
      "file:///mnt"
    ];
  };

  qt = {
    enable = true;
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };
}
