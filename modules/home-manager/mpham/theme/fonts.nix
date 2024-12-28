# fonts.nix

{ lib, pkgs, ... }:

{
  home.packages = [
    pkgs.nerd-fonts.iosevka
    pkgs.nerd-fonts.noto
  ];

  fonts.fontconfig = {
    enable = true;

    defaultFonts = {
      serif = [ "NotoSerif Nerd Font" ];
      sansSerif = [ "NotoSans Nerd Font" ];
      monospace = [ "NotoSansM Nerd Font" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  gtk.font = {
    name = "NotoSans Nerd Font";
    package = pkgs.nerd-fonts.noto;
    size = 12;
  };

  home.activation = {
    # sometimes required when updating fonts, so automating here
    font-cache-refresh = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${pkgs.fontconfig}/bin/fc-cache -r
    '';
  };
}
