# fonts.nix

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "Iosevka" "Noto" ];})
    # noto-fonts-cjk
    # noto-fonts-emoji
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
    package = pkgs.nerdfonts.override { fonts = [ "Noto" ]; };
    size = 12;
  };
}
